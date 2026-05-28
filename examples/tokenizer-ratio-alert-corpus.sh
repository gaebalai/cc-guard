#!/bin/bash
# tokenizer-ratio-alert-corpus.sh — 개인 corpus의 input_tokens/character_count 비율 drift 감지 (PostToolUse rolling baseline 방식)
# 관련: examples/tokenizer-ratio-alert.sh는 동명 다른 설계의 PreToolUse + Anthropic API count_tokens 경유 버전 (Postmortems Incident 5)
# Why: Anthropic이 토크나이저를 silent하게 변경 (#46829 관련, Opus 4.7에서 1.35-1.46× 인플레이션 실측 Simon Willison 2026-04-20).
#      개인 corpus에 대해 input_tokens / character_count를 7일 rolling baseline과 비교하여,
#      1.25× threshold를 3 연속 session에서 초과하면 alert.
#      Path A (Stay-and-Fortify) defense — rolling-baseline tokenizer drift detection.
# Event: PostToolUse  MATCHER: ""
# Action: 각 turn의 input_tokens를 로그, baseline drift 감지 시 stderr alert (non-blocking)

HISTORY="/tmp/cc-tokenizer-ratio-history"
SESSION_FLAG="/tmp/cc-tokenizer-ratio-session"
TODAY=$(date +%Y-%m-%d)

# stdin에서 JSON 취득 (Claude Code PostToolUse hook input)
INPUT=$(cat 2>/dev/null || echo "{}")

# tool_input에서 approximate character count 계산 (text-like fields 길이 합계)
CHARS=$(echo "$INPUT" | jq -r '
  .tool_input // {} |
  [.. | strings] |
  map(length) |
  add // 0
' 2>/dev/null)

# tool_response에서 input_tokens 취득 (사용 가능한 경우)
TOKENS=$(echo "$INPUT" | jq -r '
  .tool_response // {} |
  .usage.input_tokens //
  .input_tokens //
  0
' 2>/dev/null)

# 둘 중 하나라도 0이면 처리 중단 (signal 부족, log 오염 방지)
[ -z "$CHARS" ] || [ "$CHARS" = "0" ] && exit 0
[ -z "$TOKENS" ] || [ "$TOKENS" = "0" ] && exit 0

# 비율 계산 (tokens / chars)
RATIO=$(awk "BEGIN { printf \"%.4f\", $TOKENS / $CHARS }")

# log: timestamp|date|tokens|chars|ratio
echo "$(date +%s)|$TODAY|$TOKENS|$CHARS|$RATIO" >> "$HISTORY"

# 7일 rolling baseline 계산 (8일 이상 이전은 제외, POSIX awk safe로 mean 채택)
SEVEN_DAYS_AGO=$(date -d "7 days ago" +%s 2>/dev/null || date -v-7d +%s 2>/dev/null)
[ -z "$SEVEN_DAYS_AGO" ] && exit 0

BASELINE=$(awk -F'|' -v cutoff="$SEVEN_DAYS_AGO" '
  $1 >= cutoff { sum += $5; n++ }
  END {
    if (n < 50) exit 1  # baseline 미확립 (50 turn 미만)
    print sum / n
  }
' "$HISTORY" 2>/dev/null)

# baseline 미확립 시 exit (50 turn 축적 대기, blocking 없음)
[ -z "$BASELINE" ] && exit 0

# 1.25× threshold 체크
THRESHOLD=$(awk "BEGIN { printf \"%.4f\", $BASELINE * 1.25 }")
EXCEEDS=$(awk "BEGIN { print ($RATIO > $THRESHOLD) ? 1 : 0 }")

# 3 연속 session 초과 판정
SESSION_ID="${CLAUDE_SESSION_ID:-default}"
LAST_SESSION=$(head -1 "$SESSION_FLAG" 2>/dev/null | cut -d'|' -f1)
EXCEED_COUNT=$(head -1 "$SESSION_FLAG" 2>/dev/null | cut -d'|' -f2)
EXCEED_COUNT=${EXCEED_COUNT:-0}

if [ "$EXCEEDS" = "1" ]; then
  if [ "$LAST_SESSION" != "$SESSION_ID" ]; then
    EXCEED_COUNT=$((EXCEED_COUNT + 1))
    echo "$SESSION_ID|$EXCEED_COUNT" > "$SESSION_FLAG"
  fi
  if [ "$EXCEED_COUNT" -ge 3 ]; then
    echo "[tokenizer-ratio-alert-corpus] tokens/chars ratio ${RATIO} exceeds 1.25x baseline (${BASELINE}) for ${EXCEED_COUNT} consecutive sessions. Tokenizer may have shifted (Issue #46829 / Opus 4.7 inflation pattern). Review your /usage --json output." >&2
  fi
else
  # 비율 정상 = 연속 카운터 reset
  echo "$SESSION_ID|0" > "$SESSION_FLAG"
fi

exit 0
