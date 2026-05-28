#!/bin/bash
# wellness-break-reminder.sh — Remind the user to take a body break
#
# What this is: a hook that watches your Claude Code session and, after
# you've been working without a noticed pause for ~90 minutes, prints a
# short reminder to your terminal: did you drink water, did you stand up,
# is your back okay?
#
# Why this exists: AI coding assistants make long sessions feel shorter
# than they are. Tokens flow, code gets written, time passes. The token
# usage warning (long-session-reminder.sh) handles the cost side. This
# hook handles the body side, which the existing wellness/posture
# literature suggests is the part that quietly accumulates harm.
#
# Tone: this is meant to feel like a colleague leaning over your desk,
# not a popup ad. It fires at most once per 30 minutes, even if the
# 90-minute threshold has been exceeded for hours, so it won't nag.
#
# TRIGGER: PostToolUse  MATCHER: ""
# (empty matcher = fires on every tool use, but we throttle internally)
#
# CONFIG:
#   CC_WELLNESS_FIRST_MIN=90    처음 알림이 나오기까지의 분 수 (기본 90분)
#   CC_WELLNESS_REPEAT_MIN=30   반복 알림의 최소 간격 (기본 30분)
#   CC_WELLNESS_OFF=1           완전히 비활성화 (지금 집중하고 싶을 때 등)

# stdin을 읽어도 사용하지 않는다 (PostToolUse hook의 입력 JSON은 무시)
cat > /dev/null

[ "${CC_WELLNESS_OFF:-0}" = "1" ] && exit 0

FIRST_THRESHOLD_MIN="${CC_WELLNESS_FIRST_MIN:-90}"
REPEAT_INTERVAL_MIN="${CC_WELLNESS_REPEAT_MIN:-30}"

START_FLAG="$HOME/.claude/wellness-session-start"
LAST_REMIND="$HOME/.claude/wellness-last-reminder"

# 첫 작업에서 세션 시작 시각을 기록
if [ ! -f "$START_FLAG" ]; then
    date +%s > "$START_FLAG"
    exit 0
fi

# Claude Code 세션이 종료된 시점에 START_FLAG가 남아 있으면
# 다음 세션에서 잘못된 시각이 사용된다. 원래는 stop hook 등에서 지워야 하지만
# 여기서는 12시간 이상 경과한 flag는 너무 오래된 것으로 간주하고 다시 생성한다
START_EPOCH=$(cat "$START_FLAG" 2>/dev/null)
NOW_EPOCH=$(date +%s)
if [ -z "$START_EPOCH" ]; then
    date +%s > "$START_FLAG"
    exit 0
fi
ELAPSED_SEC=$(( NOW_EPOCH - START_EPOCH ))
if [ "$ELAPSED_SEC" -lt 0 ] || [ "$ELAPSED_SEC" -gt 43200 ]; then
    # 12시간(43200초)을 초과했다면 stale flag로 보고 새로 만든다
    date +%s > "$START_FLAG"
    : > "$LAST_REMIND"
    exit 0
fi

ELAPSED_MIN=$(( ELAPSED_SEC / 60 ))

# 아직 임계값에 도달하지 않음
if [ "$ELAPSED_MIN" -lt "$FIRST_THRESHOLD_MIN" ]; then
    exit 0
fi

# 직전 리마인더 시각을 확인하고 반복 간격을 지킨다
# stale-reset 경로에서 `: > "$LAST_REMIND"`가 빈 파일을 남기는 경로가 있고,
# 빈 값 또는 비숫자 내용을 읽으면 뒤따르는 `[ -gt 0 ]`에서 integer error가 발생해
# throttle이 bypass된다. 빈 값 / 비숫자는 0 취급으로 정규화한다 (PR #137 Codex review fix)
LAST_EPOCH=0
if [ -f "$LAST_REMIND" ]; then
    LAST_EPOCH_RAW=$(cat "$LAST_REMIND" 2>/dev/null)
    case "$LAST_EPOCH_RAW" in
        ''|*[!0-9]*) LAST_EPOCH=0 ;;
        *) LAST_EPOCH="$LAST_EPOCH_RAW" ;;
    esac
fi
SINCE_LAST_MIN=$(( (NOW_EPOCH - LAST_EPOCH) / 60 ))
if [ "$LAST_EPOCH" -gt 0 ] && [ "$SINCE_LAST_MIN" -lt "$REPEAT_INTERVAL_MIN" ]; then
    exit 0
fi

# 메시지를 하나 골라서 출력한다 (작업 시간에 따라 내용을 바꾼다)
HOURS=$(( ELAPSED_MIN / 60 ))
MINS=$(( ELAPSED_MIN % 60 ))

if [ "$HOURS" -lt 2 ]; then
    cat >&2 <<EOF

🫖 세션이 ${HOURS}시간 ${MINS}분째 이어지고 있다.
  커피가 식어 있지는 않은지? 물 한 잔 어떤가.
  3분 정도 일어나서 어깨를 돌리면, 아마 다음 판단이 조금 달라질 것이다.
  (이 리마인더를 끄려면 CC_WELLNESS_OFF=1)
EOF
elif [ "$HOURS" -lt 4 ]; then
    cat >&2 <<EOF

🪟 벌써 ${HOURS}시간 ${MINS}분이 지났다.
  화면에서 눈을 떼고, 3미터 앞에 있는 물체를 30초 동안 바라봐 보라.
  일어나서 컵에 물을 따르고, 화장실에 다녀온다. 코드는 여기서 기다리고 있다.
  AI인 나에게는 몸이 없지만, 당신에게는 있다.
EOF
else
    cat >&2 <<EOF

🌙 ${HOURS}시간 ${MINS}분. 장시간 작업이다.
  슬슬 나머지는 내일로 미루는 게 어떨까. 남은 판단의 질은 지금의 어깨나 목 통증과
  아마 상관관계가 있다. git commit하고, 화면을 닫고, 침대로.
  나는 당신이 돌아왔을 때, 언제든 이어서 작업할 수 있다.
EOF
fi

# 직전 리마인더 시각을 갱신

exit 0
