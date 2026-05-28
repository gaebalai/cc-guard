#!/bin/bash
# worktree-branch-pollution-detector.sh — worktree가 부모 브랜치를 오염시키지 않았는지 감지
# Why: 서브에이전트의 worktree 조작이 부모 레포를 예기치 않은 브랜치로 이동시켜,
#      의도하지 않은 commit-to-main이 발생한다. 1주일에 3건의 사고 보고 있음 (#50207)
# Event: PostToolUse  MATCHER: Bash
# Action: 현재 브랜치가 기대값과 다른 경우 경고

INPUT=$(cat)

# 기대 브랜치 (세션 시작 시 기록)
EXPECTED_BRANCH_FILE="/tmp/cc-expected-branch-$(pwd | md5sum | cut -c1-8)"

# git 관리 하가 아니면 스킵
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
[ -z "$CURRENT_BRANCH" ] && exit 0

# 첫 실행 시 브랜치를 기록
if [ ! -f "$EXPECTED_BRANCH_FILE" ]; then
  echo "$CURRENT_BRANCH" > "$EXPECTED_BRANCH_FILE"
  exit 0
fi

EXPECTED_BRANCH=$(cat "$EXPECTED_BRANCH_FILE" 2>/dev/null)

if [ "$CURRENT_BRANCH" != "$EXPECTED_BRANCH" ]; then
  echo "⚠ BRANCH CHANGED: Expected '$EXPECTED_BRANCH' but now on '$CURRENT_BRANCH'" >&2
  echo "This may be caused by a worktree or subagent switching your branch." >&2
  echo "Run 'git checkout $EXPECTED_BRANCH' to return. See: #50207" >&2
  # 새 브랜치를 기록 (의도적 전환일 수 있음)
  echo "$CURRENT_BRANCH" > "$EXPECTED_BRANCH_FILE"
fi

exit 0
