# Example Hooks

677 installable hooks. Each solves a real problem from GitHub Issues or autonomous operation. 9,228+ tests.

```bash
npx @gaebalai/cc-guard --install-example <name>   # install one
npx @gaebalai/cc-guard --examples                  # list all
npx @gaebalai/cc-guard --examples safety           # filter by category
npx @gaebalai/cc-guard --shield                    # install recommended set
```

## Categories

| Category | Count | Examples |
|----------|-------|---------|
| Destructive Command Prevention | 14 | `destructive-guard`, `branch-guard`, `no-sudo-guard`, `symlink-guard`, `shell-wrapper-guard`, `compound-inject-guard` |
| Data Protection | 5 | `block-database-wipe`, `secret-guard`, `hardcoded-secret-detector` |
| Git Safety | 11 | `git-config-guard`, `no-verify-blocker`, `push-requires-test-pass` |
| Auto-Approve (PreToolUse) | 11 | `auto-approve-readonly`, `auto-approve-build`, `auto-approve-docker` |
| Auto-Approve (PermissionRequest) | 7 | `allow-git-hooks-dir`, `allow-protected-dirs`, `edit-always-allow` |
| Code Quality | 10 | `syntax-check`, `diff-size-guard`, `test-deletion-guard` |
| Security | 10 | `credential-file-cat-guard`, `credential-exfil-guard`, `prompt-injection-guard` |
| Deploy | 4 | `deploy-guard`, `no-deploy-friday`, `work-hours-guard` |
| Monitoring & Cost | 14 | `context-monitor`, `cost-tracker`, `loop-detector`, `edit-error-counter`, `dotenv-watch` |
| Utility | 20 | `comment-strip`, `session-handoff`, `auto-checkpoint`, `edit-retry-loop-guard`, `direnv-auto-reload`, `pre-compact-checkpoint` |

## Popular Hooks

- **`auto-approve-readonly`** — Skip prompts for `cat`, `ls`, `grep`, `git status`
- **`destructive-guard`** — Block `rm -rf`, `git reset --hard`
- **`credential-file-cat-guard`** — Block reading `.netrc`, `.npmrc`, `.cargo/credentials`
- **`push-requires-test-pass`** — Block `git push main` without passing tests
- **`context-monitor`** — Warn at 40/25/20/15% context remaining

## Guides

- [Auto-Approve Guide](https://claudecode.to/cc-guard/auto-approve-guide.html)
- [Credential Protection](https://claudecode.to/cc-guard/prevent-credential-leak.html)
- [OWASP MCP Top 10 Defense](https://claudecode.to/cc-guard/owasp-mcp-hooks.html)
- [COOKBOOK](../COOKBOOK.md)

## Token Optimization

Using too many tokens? These hooks help monitor and reduce consumption:

- **`token-budget-guard`** — Alert when session exceeds token budget
- **`large-read-guard`** — Block reading files over 1000 lines
- **`context-monitor`** — Track context window usage

For a quick diagnostic: try the [free Token Checkup](https://claudecode.to/cc-guard/token-checkup.html) — 30-second consumption analysis with hook recommendations.

## Write Your Own

See [CONTRIBUTING.md](../CONTRIBUTING.md).
