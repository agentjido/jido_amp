# AGENTS.md - Jido.Amp

Guidance for coding agents working in this repository.

## Scope

`jido_amp` is a harness-first adapter around `amp_sdk`.

Current architecture:

- `Jido.Amp` - adapter-focused top-level API and compatibility-gated run/execute
- `Jido.Amp.Adapter` - `Jido.Harness.Adapter` implementation
- `Jido.Amp.Mapper` - maps Amp SDK stream messages to `Jido.Harness.Event`
- `Jido.Amp.Compatibility` - Amp CLI fail-fast checks for streaming capability
- `Jido.Amp.Options` - Zoi-backed options normalization to `%AmpSdk.Types.Options{}`
- Mix tasks:
  - `mix amp.install`
  - `mix amp.compat`

## Design Rules

1. Stability first
- `Jido.Amp.run/2` and `Jido.Amp.execute/2` must fail fast on incompatible Amp CLI.
- Do not silently fallback to non-streaming behavior in these APIs.

2. Curated top-level API
- Keep `Jido.Amp` focused on adapter execution and diagnostics.
- Avoid adding broad provider management wrappers here.
3. Validation and errors
- Use Zoi for structured options validation.
- Use `Jido.Amp.Error` (`Splode`) for structured errors.

4. Testability
- Prefer dependency injection via `Application.get_env/3` where external runtime dependencies are involved (CLI/sdk/commands).
- Keep integration tests tagged and opt-in.

## Quality Gate

Before finishing changes:

```bash
mix compile --warnings-as-errors
mix test
mix credo --strict
mix doctor --raise
```

Coverage threshold is enforced in project config (>=90%).

## Commits

- Use conventional commits: `type(scope): description`
- Do not modify `CHANGELOG.md`; release notes are generated from Git history during release, so keep changes focused on proper Conventional Commits.
- Never include `ampcode` as a contributor/co-author
