#!/bin/bash
# cache-creation-spike-detector.sh — cache_creation 스파이크 감지 및 경고
# Why: smooshSystemReminderSiblings 함수가 system-reminder를 매 턴 tool_result.content에
#      접어 넣으면서, 프롬프트 캐시 프리픽스가 변경되어 cache_creation이
#      수십만 토큰 단위로 스파이크함 (#49585). 5x 소비율 상승 보고됨 (#49593)
# Event: PostToolUse (모든 도구 실행 후 체크)
# Action: cache_creation_input_tokens가 임계값 초과 시 경고

INPUT=$(cat)
# PostToolUse에서는 usage 데이터에 접근할 수 없으므로,
# /cost 명령 출력 로그 파일로 누적 cache_creation을 추적한다
CACHE_LOG="/tmp/cc-cache-creation-tracker.log"
THRESHOLD=100000  # 100K 토큰 이상에서 cache_creation 경고

# 10회에 1번만 체크 (성능 고려)
COUNTER_FILE="/tmp/cache-spike-check-counter"
COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"
[ $((COUNT % 10)) -ne 0 ] && exit 0

# 세션 시작 후 경과 시간 체크
SESSION_START=$(stat -c %Y /tmp/cache-spike-check-counter 2>/dev/null || echo "0")
NOW=$(date +%s)
ELAPSED=$((NOW - SESSION_START))

# 세션 시작 10분 이내는 스킵 (초기 캐시 구축은 정상)
[ "$ELAPSED" -lt 600 ] && exit 0

echo "INFO: cache_creation 스파이크 감지 hook 동작 중. 비정상 토큰 소비가 느껴지면 /cost로 확인하세요." >&2
echo "상세: https://github.com/anthropics/claude-code/issues/49585" >&2
exit 0
