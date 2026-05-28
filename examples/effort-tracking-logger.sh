#!/bin/bash
# effort-tracking-logger.sh — 도구 사용마다 effort 로그 기록
# Why: OTEL 호환 effort 추적에 대한 요청 급증 (#49893, 18👍).
#      공식 대응을 기다리지 않고, hook으로 도구 호출마다 로그를 남긴다.
#      비용 분석·세션 회고·병목 식별에 활용 가능.
# Event: PostToolUse  MATCHER: ""
# Output: ~/.claude/effort-log/YYYY-MM-DD.jsonl

LOG_DIR="${HOME}/.claude/effort-log"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).jsonl"

# stdin에서 도구 정보 취득
TOOL_INPUT=$(cat)
TOOL_NAME=$(echo "$TOOL_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name','unknown'))" 2>/dev/null)
TOOL_STATUS=$(echo "$TOOL_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('was_error','false'))" 2>/dev/null)

# JSONL 로그에 추가 기록
python3 -c "
import json, datetime
entry = {
    'timestamp': datetime.datetime.now().isoformat(),
    'tool': '$TOOL_NAME',
    'error': '$TOOL_STATUS' == 'true',
    'session_pid': $(echo $$)
}
print(json.dumps(entry))
" >> "$LOG_FILE"

exit 0
