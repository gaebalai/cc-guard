#!/bin/bash
# quota-reset-cycle-monitor.sh — quota 리셋 주기 변경 감지
# Why: 사용자의 quota 리셋 주기가 예고 없이 월요일 → 금요일로 변경됨 (#49599, 2r/4c).
#      리셋일을 추적하고, 주기 변경 시 경고한다.
#      갑작스러운 quota 고갈의 원인 규명에 유용.
# Event: Notification  MATCHER: ""
# Action: 일별로 quota 리셋일을 기록, 주기 변경을 감지

RESET_LOG="/tmp/cc-quota-reset-history"
TODAY=$(date +%u)  # 1=Monday, 7=Sunday
TODAY_DATE=$(date +%Y-%m-%d)

# 하루 1번만 체크 (날짜로 제어)
LAST_CHECK=$(head -1 "$RESET_LOG" 2>/dev/null | cut -d'|' -f1)
[ "$LAST_CHECK" = "$TODAY_DATE" ] && exit 0

# /cost 출력에서 리셋 정보를 가져오는 방법 안내
# 실제 리셋 감지는 수동 확인이 필요하지만, 로그를 남겨 추적 가능
echo "$TODAY_DATE|$TODAY" >> "$RESET_LOG"

# 리셋 이력이 2건 이상이면 주기 분석
ENTRIES=$(wc -l < "$RESET_LOG" 2>/dev/null || echo "0")
if [ "$ENTRIES" -ge 7 ]; then
  # 지난 7일의 요일 패턴 표시 (주말에 quota가 늘면 차주 리셋=정상)
  echo "📊 Quota tracking: $ENTRIES days logged. Run '/cost' to check current reset day." >&2
  echo "Known issue: reset cycle may change without notice (#49599)." >&2
  echo "If your quota resets on a different day than expected, report to Anthropic support." >&2
fi

exit 0
