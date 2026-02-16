# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `Jido.Amp.Compatibility` fail-fast runtime checks for Amp CLI streaming capability.
- `mix amp.compat` task for explicit compatibility diagnostics.
- `Jido.Amp.Options` (Zoi-backed) conversion to `%AmpSdk.Types.Options{}`.
- Namespaced full-parity wrapper modules:
  - `Jido.Amp.Threads`
  - `Jido.Amp.Tools`
  - `Jido.Amp.Permissions`
  - `Jido.Amp.MCP`
  - `Jido.Amp.Tasks`
  - `Jido.Amp.Review`
  - `Jido.Amp.Skills`
- Typed custom signals:
  - `Jido.Amp.Signal.SessionStart`
  - `Jido.Amp.Signal.Thinking`
- Agent route for `"amp.session.start"`.
- Coverage and test suite expansion for stream runner, wrappers, options, and mix tasks.
- Packaging hardening files (`LICENSE`, `config/*`, CI/release workflows).

### Changed
- `Jido.Amp.run/2` and `Jido.Amp.execute/2` now enforce compatibility checks before streaming.
- `Jido.Amp.Actions.HandleMessage` now maps `ThinkingContent` to `amp.turn.thinking`.
- Session ID resolution now prefers message `session_id`, then falls back to agent state.
- `mix amp.thread` now supports better invalid option formatting and dependency injection hooks for testing.
- Project metadata updated to enforce >=90% coverage and preferred test envs for coveralls.

### Removed
- Legacy orchestrator-era architecture references from docs.
- `jido_dep/4` dependency helper in `mix.exs`.

### Migration Notes
- Docs/examples using `Jido.Amp.Orchestrator` or `Jido.Amp.Tool` are obsolete.
- Use `Jido.Amp.run/2` or `Jido.Amp.execute/2` for execution.
- Use namespaced modules for advanced management operations.
- If compatibility fails in an environment, run `mix amp.compat`; direct thread execution remains available via `mix amp.thread`.
