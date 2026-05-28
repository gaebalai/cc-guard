#!/bin/bash
# subagent-spawn-rate-monitor.sh — 서브에이전트의 과도한 spawn 감지
# Why: 서브에이전트는 매번 spawn될 때마다 ~4.7K 토큰이 cache_creation
#      (1.25x 비용)으로 과금된다. spawn-heavy 워크플로에서는 선형으로 증가하여,
#      사용자가 모르는 사이에 quota를 소모한다 (#50213, #46968)
# Event: PreToolUse  MATCHER: Agent
# Action: 단시간에 다수의 Agent spawn이 있으면 경고

COUNTER_FILE="/tmp/cc-subagent-spawn-counter"
WINDOW_FILE="/tmp/cc-subagent-spawn-window"
THRESHOLD=5      # 이 횟수를 초과하면 경고
WINDOW_SECS=300  # 5분 윈도

NOW=$(date +%s)
WINDOW_START=$(cat "$WINDOW_FILE" 2>/dev/null || echo "$NOW")
COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")

# 윈도 만료 시 리셋
ELAPSED=$((NOW - WINDOW_START))
if [ "$ELAPSED" -gt "$WINDOW_SECS" ]; then
  COUNT=0
  echo "$NOW" > "$WINDOW_FILE"
fi

COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

if [ "$COUNT" -gt "$THRESHOLD" ]; then
  echo "⚠ HIGH SUBAGENT SPAWN RATE: $COUNT agents spawned in ${ELAPSED}s" >&2
  echo "Each spawn costs ~4.7K tokens at 1.25x rate (no cache_control)." >&2
  echo "Consider batching tasks or using fewer parallel agents. See: #50213" >&2
fi

exit 0
