#!/bin/bash
# thinking-display-enforcer.sh — Opus 4.7 thinking summaries 미표시 감지
# Why: Opus 4.7에서 thinking display의 기본값이 summarized → omitted로 변경됨 (#49268, 17👍)
# 세션 시작 시 모델을 확인하고, Opus 4.7에서 thinking이 비표시인 경우 경고한다
# Event: Notification (세션 시작 시 확인)
# Fix: claude --thinking-display summarized

# 체크 빈도 제어 (100회에 1회)
COUNTER_FILE="/tmp/thinking-display-check-counter"
COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"
[ $((COUNT % 100)) -ne 1 ] && exit 0

# settings.json에 thinking display 설정이 있는지 확인
SETTINGS_FILE="${HOME}/.claude/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
    HAS_THINKING=$(grep -c "showThinkingSummaries\|thinkingDisplay" "$SETTINGS_FILE" 2>/dev/null || echo "0")
    if [ "$HAS_THINKING" -eq 0 ]; then
        echo "INFO: Opus 4.7에서는 thinking summaries가 기본적으로 비표시입니다." >&2
        echo "수정: claude --thinking-display summarized 로 시작하거나, settings.json에 설정을 추가하세요." >&2
        echo "상세: https://github.com/anthropics/claude-code/issues/49268" >&2
    fi
fi
exit 0
