# Changelog

## [1.0.0] - 2026-05-29

Initial stable release. Consolidated all prior development into a single 1.0.0 milestone.

### Core
- One-command install: `npx cc-guard` deploys 8 safety hooks in 10 seconds, zero dependencies.
- 8 built-in hooks:
  - destructive-guard (rm -rf, git reset --hard, git clean, sudo rm -rf, PowerShell Remove-Item, WSL2 /mnt paths)
  - branch-guard (main/master push protection, --force on all branches, force-with-lease, HEAD:main)
  - secret-guard (.env, credential files, id_rsa, .pem, git add . with .env present)
  - syntax-check (Python, Shell, JSON, YAML, JS)
  - context-monitor (graduated warnings at 40/25/20/15%)
  - comment-strip ([#29582](https://github.com/anthropics/claude-code/issues/29582))
  - cd-git-allow ([#32985](https://github.com/anthropics/claude-code/issues/32985))
  - api-error-alert (rate limit / auth failure / server error notifications)

### Example hooks (772)
- Categories: Safety Guards, Auto-Approve, Quality, Recovery, UX, CI/CD, Cloud/Infra, MCP Security, Role-based, Session Protection, Process, OWASP.
- Session protection hooks (token waste / session loss): cch-cache-guard, image-file-validator, large-read-guard, prompt-usage-logger, compact-alert-notification, token-budget-guard, session-index-repair, session-backup-on-start, working-directory-fence, pre-compact-transcript-backup, read-before-edit, subagent-error-detector, subagent-identity-leak-guard, subagent-tool-allowlist-enforcer, subagent-spawn-verification-enforcer, subagent-destructive-git-guard, trustfall-mcp-injection-guard, mcp-startup-bloat-detector, stale-temp-settings-detector.
- v2.1.83+ event hooks: direnv-auto-reload (CwdChanged), dotenv-watch (FileChanged), pre-compact-checkpoint (PreCompact).

### CLI (56 commands)
- Install / discovery: `--shield`, `--install-example`, `--examples`, `--create`
- Verification: `--verify`, `--audit`, `--doctor`, `--lint`, `--benchmark`, `--health`
- Analysis: `--dashboard`, `--stats`, `--watch`, `--analyze`, `--why`, `--replay`, `--suggest`
- Configuration: `--diff`, `--export`, `--import`, `--team`, `--profile`, `--from-claudemd`, `--guard`, `--rules`
- Diagnostics: `--quickfix`, `--score`, `--test-hook`, `--save-profile`, `--migrate-from`, `--diff-hooks`, `--report`, `--generate-ci`, `--migrate`, `--compare`, `--issues`, `--changelog`, `--init-project`, `--share`, `--status`

### Tests
- 9,228+ automated tests covering all hooks (100% coverage).
- Edge case tests: null tool_input, Unicode input, empty-field nested objects across all hooks.
- Trigger detection tests (PermissionRequest / SessionStart / PreToolUse / UserPromptSubmit / FileChanged / CwdChanged / PreCompact).

### Web tools (23)
- Hub, Audit, Cheat Sheet, Builder, FAQ, Playground, Hook Selector, Setup Wizard, Permission Checker, By Example, Migration, Matrix, Settings Reference, Troubleshooting, Recipes, Validator, OWASP MCP, Token Checkup, and more.

### Documentation
- README (ko/ja/en), COOKBOOK, TROUBLESHOOTING, SETTINGS_REFERENCE, MIGRATION.
- 71+ tracked Anthropic Issues addressed with hook workarounds.
- 5-language destructive-guard examples (bash, Python, Go, TypeScript, Rust).

### Platform
- macOS, Linux, WSL2 supported. Windows path detection in `--doctor` / `--audit`.
- Requires: `jq`, Claude Code 2.1+.

### Stats at release
- 772 example hooks · 9,228+ tests · 56 CLI commands · 23 web tools · 30K+ cumulative installs.
