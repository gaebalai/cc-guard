#!/bin/bash
# model-version-change-alert.sh — 모델 버전 변경 감지 및 경고
# Why: Opus 4.6이 모델 피커에서 갑자기 삭제됨 (#49689, 14👍).
#      사용자가 의도치 않게 다른 모델로 전환되는 사례가 다발.
#      모델이 바뀌면 hook 동작·토큰 소비·품질이 모두 달라진다.
# Event: Notification  MATCHER: ""
# Action: 이전 모델과 현재 모델을 비교, 변경 시 경고

MODEL_HISTORY="/tmp/cc-model-version-history"
CURRENT_MODEL="${CLAUDE_MODEL:-unknown}"

# Notification 이벤트 body에서 모델 정보를 가져오기 시도
if [ -n "$1" ]; then
  BODY_MODEL=$(echo "$1" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('model',''))" 2>/dev/null)
  [ -n "$BODY_MODEL" ] && CURRENT_MODEL="$BODY_MODEL"
fi

# 이전 모델 읽기
PREV_MODEL=$(cat "$MODEL_HISTORY" 2>/dev/null || echo "")

if [ -n "$PREV_MODEL" ] && [ "$PREV_MODEL" != "$CURRENT_MODEL" ] && [ "$CURRENT_MODEL" != "unknown" ]; then
  echo "⚠ MODEL CHANGED: $PREV_MODEL → $CURRENT_MODEL" >&2
  echo "Your model was switched. This affects token consumption, quality, and hook behavior." >&2
  echo "If unintended, check your settings: claude --model $PREV_MODEL" >&2
  echo "Known issue: Opus 4.6 was removed from the Desktop picker (#49689)" >&2
fi

# 현재 모델 기록
[ "$CURRENT_MODEL" != "unknown" ] && echo "$CURRENT_MODEL" > "$MODEL_HISTORY"

exit 0
