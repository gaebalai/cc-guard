#!/bin/bash
# context-usage-drift-alert.sh — 컨텍스트 사용률 급증 감지
# Why: 1M 컨텍스트 모델에서 실제 124% 사용 중에 UI상 60%로 표시되는 문제 (#50204).
#      예고 없이 auto-compact가 발화하여 컨텍스트가 소실된다.
#      도구 호출 횟수로 컨텍스트 소비를 추정하여 경고한다.
# Event: PostToolUse  MATCHER: ""
# Action: 세션 내 도구 호출 횟수가 임계값을 초과하면 경고

COUNTER_FILE="/tmp/cc-context-usage-counter-$$"
# 세션 PID가 바뀌면 새 카운터가 됨
# 폴백: 부모 PID로 그룹화
if [ ! -f "$COUNTER_FILE" ]; then
  COUNTER_FILE="/tmp/cc-context-usage-counter-$(date +%Y%m%d)"
fi

COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

# 50회: 주의 환기, 100회: 강한 경고, 150회: compact 권장
if [ "$COUNT" -eq 50 ]; then
  echo "📊 Session checkpoint: $COUNT tool calls. Context may be growing large." >&2
  echo "Run /cost to check actual usage. UI display may undercount by 2x (#50204)." >&2
elif [ "$COUNT" -eq 100 ]; then
  echo "⚠ HIGH CONTEXT USAGE: $COUNT tool calls this session." >&2
  echo "UI may show ~50% when actual usage is near 100%. Consider /compact." >&2
  echo "Unexpected auto-compact can erase your working context. See: #50204" >&2
elif [ "$COUNT" -eq 150 ]; then
  echo "🚨 VERY HIGH CONTEXT: $COUNT tool calls. Auto-compact likely imminent." >&2
  echo "Save important state to files NOW. Run /compact manually to control what's kept." >&2
fi

exit 0
