# cc-guard

**Claude Code를 안전하게 만드는 원커맨드 도구.** 772개의 example hook · 71건 이상의 Anthropic 공식 Issue에 대응 · 9,228+ 테스트 · 

```bash
npx @gaebalai/cc-guard
```

10초 만에 8개의 안전 hook을 설치한다. `rm -rf /` 차단, main 브랜치 push 방지, 시크릿 유출 감지, 구문 오류 자동 검출. 의존성 제로.

> **hook이란?** Claude Code가 명령을 실행하기 전에 내용을 검사하고 위험하면 중단시키는 구조. 공항의 보안 검색대와 같다 — 탑승구(명령 실행) 앞에 체크포인트(hook)가 있어, 위험물(rm -rf 등)을 소지하고 있으면 통과시키지 않는다.

## 기능

| 명령 | 기능 |
|---|---|
| `npx @gaebalai/cc-guard` | 8개의 안전 hook 설치 |
| `--shield` | 최대 안전(stack 감지 + 권장 hook 자동 선택) |
| `--install-example <name>` | 772개의 example 중 개별 설치 |
| `--examples` | 모든 example 일람 표시 |
| `--create "설명"` | 자연어로 커스텀 hook 생성 |
| `--verify` | 각 hook의 동작 확인 |
| `--audit` | 안전 스코어(0-100) |
| `--doctor` | 동작하지 않는 원인 진단 |
| `--dashboard` | 차단 통계 대시보드 |
| `--stats` | 차단 통계 리포트 |
| `--lint` | 설정의 정적 분석 |
| `--benchmark` | hook 실행 속도 측정 |
| `--diff <file>` | 설정 비교 |
| `--watch` | 차단된 명령을 실시간으로 표시 |
| `--export / --import` | 팀에서 설정 공유 |
| `--team` | 프로젝트에 커밋해 공유 |

56개의 CLI 명령 전체 리스트: `npx @gaebalai/cc-guard --help`

## 설치

```bash
npx @gaebalai/cc-guard
```

Claude Code 재시작. 완료.

## 차단되는 동작

| 동작 | Before | After |
|---|---|---|
| `rm -rf /` | 실행됨 | 차단 |
| `git push --force` | 실행됨 | 차단 |
| `git push origin main` | 실행됨 | 차단 |
| `git add .env` | 실행됨 | 차단 |
| `cat ~/.netrc` | 토큰 표시 | 차단 |
| Python 구문 오류 | 알아차리지 못함 | 자동 감지 |
| 컨텍스트 고갈 | 갑작스러운 종료 | 단계적 경고 |
| CLAUDE.md 규칙 소실 | 압축 후 무시 | 자동 재주입 |
| 서브에이전트의 지시 무시 | v2.1.84 이후 CLAUDE.md 제외 ([#40459](https://github.com/anthropics/claude-code/issues/40459)) | hook으로 제약 |
| 읽지 않고 편집 | 6%→34%로 증가 ([#42796](https://github.com/anthropics/claude-code/issues/42796)) | 경고 |

> 📘 token 소비가 너무 많은가? [Token Checkup](https://claudecode.to/cc-guard/token-checkup.html) 무료 진단 도구로 30초 만에 자신의 소비 패턴을 확인할 수 있다. CLAUDE.md 최적화 · hook을 통한 token 제어 · 컨텍스트 관리 · 워크플로 설계 가이드는 [COOKBOOK](./COOKBOOK.md)과 [hook 예제](./examples/)를 참고한다.

**알려진 제약:**

- `FileChanged` 알림은 파일 내용을 hook의 **이전**에 컨텍스트로 주입한다. session 중에 `.env`나 `credentials.json`이 외부에서 변경된 경우 hook으로 차단할 수 없다([#44909](https://github.com/anthropics/claude-code/issues/44909)). 대책: `dotenv-watch`로 경고를 수신하고, Claude Code 실행 중에는 기밀 파일을 편집하지 않는다.

## Session 보호 hook

session의 손상이나 token 낭비를 방지하는 hook.

| hook | 해결하는 문제 | Issue |
|--------|-------------|-------|
| `cch-cache-guard` | session 파일 읽기로 인한 cache 오염 차단 | [#40652](https://github.com/anthropics/claude-code/issues/40652) |
| `image-file-validator` | 가짜 이미지 파일(텍스트의 .png) 읽기 차단 | [#24387](https://github.com/anthropics/claude-code/issues/24387) |
| `large-read-guard` | 큰 파일의 cat에 의한 컨텍스트 낭비 경고 | [#41617](https://github.com/anthropics/claude-code/issues/41617) |
| `prompt-usage-logger` | 모든 prompt를 로깅해 token 소비 패턴 추적 | [#41249](https://github.com/anthropics/claude-code/issues/41249) |
| `compact-alert-notification` | auto-compaction 발화 알림(token 낭비 사이클 감지) | [#41788](https://github.com/anthropics/claude-code/issues/41788) |
| `token-budget-guard` | session 비용 상한 초과 시 tool 호출 차단 | [#38335](https://github.com/anthropics/claude-code/issues/38335) |
| `session-index-repair` | 종료 시 sessions-index.json 재구축(`--resume`로 session 소실 방지) | [#25032](https://github.com/anthropics/claude-code/issues/25032) |
| `session-backup-on-start` | 시작 시 session JSONL 백업(임의의 삭제로부터 보호) | [#41874](https://github.com/anthropics/claude-code/issues/41874) |
| `working-directory-fence` | CWD 밖의 Read/Edit/Write 차단(다른 프로젝트에서의 오작업 방지) | [#41850](https://github.com/anthropics/claude-code/issues/41850) |
| `pre-compact-transcript-backup` | compaction 전에 JSONL 전체 백업(rate limit 시 데이터 손실 방지) | [#40352](https://github.com/anthropics/claude-code/issues/40352) |
| `read-before-edit` | 읽지 않고 편집하는 패턴을 감지해 경고(Read:Edit 비율이 70% 저하 — [#42796](https://github.com/anthropics/claude-code/issues/42796)) | [#42796](https://github.com/anthropics/claude-code/issues/42796) |
| `subagent-error-detector` | 서브에이전트의 529/502/timeout 결과를 감지해 경고 | [#41911](https://github.com/anthropics/claude-code/issues/41911) |
| `subagent-identity-leak-guard` | 자식 에이전트가 부모의 신분을 사칭하거나 부모의 대화 이력을 누설하는 것을 예방(delegation prompt의 신분 경계 검사) | [#55488](https://github.com/anthropics/claude-code/issues/55488) |
| `subagent-tool-allowlist-enforcer` | 자식 에이전트의 도구 경계를 delegation prompt로 명시하고, 부모의 검증 절차를 유도(허위 보고 예방) | [#55653](https://github.com/anthropics/claude-code/issues/55653) |
| `subagent-spawn-verification-enforcer` | 자식 에이전트의 spawn 응답이 허위가 아닌지 산출물의 검증 절차로 예방 | [#55666](https://github.com/anthropics/claude-code/issues/55666) |
| `subagent-destructive-git-guard` | 자식 에이전트의 delegation prompt에서 destructive한 git 명령의 금지와 안전한 대체(git stash) 및 working tree 상태 확인 지시가 명시되어 있는지 검사(4/25-5/8의 3건의 동형 data-loss 예방) | [#57463](https://github.com/anthropics/claude-code/issues/57463) / [#46444](https://github.com/anthropics/claude-code/issues/46444) / [#53765](https://github.com/anthropics/claude-code/issues/53765) |
| `trustfall-mcp-injection-guard` | clone한 repo의 `.mcp.json`과 `.claude/settings.json`에서 MCP server가 unsandboxed로 기동되는 1-click RCE를 SessionStart 단계에서 경고(Adversa AI의 TrustFall PoC 대응) | [The Register](https://www.theregister.com/security/2026/05/07/claude-code-trust-prompt-can-trigger-one-click-rce/) / [GHSA-vp62-r36r-9xqp](https://github.com/advisories/GHSA-vp62-r36r-9xqp) |
| `mcp-startup-bloat-detector` | Pro / Claude.ai-OAuth 로그인에서 `claude.ai ` 접두 connector가 대량 동기화되어 System tools 컨텍스트가 부풀어 오르는 현상을 SessionStart에서 감지하고 `ENABLE_CLAUDEAI_MCP_SERVERS=false` 회피책을 제시(v2.1.14에서 막은 줄 알았던 경로가 v2.1.133에서 29배로 재발) | [#50062](https://github.com/anthropics/claude-code/issues/50062) / [#57235](https://github.com/anthropics/claude-code/issues/57235) |
| `stale-temp-settings-detector` | 같은 머신의 다른 사용자가 `/tmp/claude-settings-*.json`을 남겨둔 경우, 데스크톱판의 `--settings '{}'` 기동이 EACCES로 충돌하는 현상을 SessionStart에서 감지하고 소유자의 이름을 표시해 삭제 판단을 지원 | [#57224](https://github.com/anthropics/claude-code/issues/57224) |

설치: `npx @gaebalai/cc-guard --install-example <이름>`

## 🚨 2026년 6월 15일 과금의 절벽
Anthropic은 [2026년 6월 15일에 programmatic 과금을 분리](https://docs.claude.com/en/api/billing)한다. `claude -p`나 SDK 호출이 다른 credit bucket으로 routing된다. 2026년 5월, 이슈로 재무적 손실 보고가 드러났다: [#61704 자신만만하지만 잘못된 billing 주장으로 €60 한도를 €84.68로 초과](https://github.com/anthropics/claude-code/issues/61704), [#61728 동작하지 않는 코드를 동작하는 것처럼 제시해 $80의 손실](https://github.com/anthropics/claude-code/issues/61728), [#61086 수정 약속 후의 malformed tool call 반복으로 token 낭비](https://github.com/anthropics/claude-code/issues/61086), [#61699 production deployment session에서의 반복적인 기만](https://github.com/anthropics/claude-code/issues/61699). **모델은 Anthropic 자신의 과금 logic을 training data로부터 검증할 수 없다.** 6월 15일 이후 모델의 billing 주장과 실제 과금 routing의 괴리는 더욱 커진다.

## 문서

- [Getting Started](https://claudecode.to/cc-guard/getting-started.html) — 5분 만에 안전하게
- [Hook Selector](https://claudecode.to/cc-guard/hook-selector.html) — 5개 질문으로 최적의 hook 세트 추천
- [Auto-Approve Guide](https://claudecode.to/cc-guard/auto-approve-guide.html) — 허가 prompt 줄이기
- [OWASP MCP 대응표](https://claudecode.to/cc-guard/owasp-mcp-hooks.html) — OWASP MCP Top 10 전체 리스크 대책
- [settings.json 레퍼런스](./SETTINGS_REFERENCE.md) — 모든 설정 해설
- [COOKBOOK](./COOKBOOK.md) — 레시피 모음
- [트러블슈팅](./TROUBLESHOOTING.md) — 동작하지 않을 때의 대처법
- [웹판 도구](https://claudecode.to/cc-guard/hub.html) — 모든 도구 일람

hook의 구조와 설정 방법은 [Claude Code 공식 문서](https://code.claude.com/docs/en/hooks)를 참조.

## 한국 환경 대응

국내 조직에서 Claude Code를 도입할 때 자주 충돌하는 규제·운영 요건과 대응 hook 매핑.

| 규제/표준 | 충돌 지점 | 대응 hook |
|---|---|---|
| **개인정보보호법(PIPA)** | LLM이 주민번호·연락처 등 개인정보를 로그/프롬프트에 노출 | `secret-guard`, `output-secret-mask`, `prompt-usage-logger` |
| **정보통신망법** | 미인가 외부 송신(외부 API·webhook 호출) | `network-guard`, `network-exfil-guard`, `webfetch-domain-allow` |
| **ISMS-P 인증** | 개발 환경 접근 통제, 변경 이력 추적, 권한 분리 | `permission-audit-log`, `working-directory-fence`, `session-backup-on-start` |
| **금융보안원 전자금융감독규정** | 운영 계정/키 노출, prod 직접 변경 | `credential-exfil-guard`, `k8s-production-guard`, `deploy-guard` |
| **공공기관 보안가이드(NIS)** | 외부 모델로의 민감정보 송출, 감사 로그 보관 | `dotenv-watch`, `prompt-usage-logger`, `permission-audit-log` |

> **주의**: cc-guard는 컴플라이언스 인증 도구가 아니며, 위 매핑은 hook을 보조 통제 수단으로 활용할 때의 출발점이다. 조직별 위험 평가와 보안 담당자 검토를 거쳐 적용한다.

설치 예: `npx @gaebalai/cc-guard --install-example permission-audit-log`

## 필요한 것

- `jq`: `brew install jq` / `apt install jq`
- Claude Code 2.1 이상

## 라이선스

MIT
