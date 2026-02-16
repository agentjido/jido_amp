# AGENTS.md - Jido.Amp

Guidance for coding agents working in this repository.

## Scope

`jido_amp` is a Jido integration around `amp_sdk`.

Current architecture:

- `Jido.Amp` - curated top-level API and compatibility-gated run/execute
- `Jido.Amp.Compatibility` - Amp CLI fail-fast checks for streaming capability
- `Jido.Amp.Options` - Zoi-backed options normalization to `%AmpSdk.Types.Options{}`
- `Jido.Amp.Agent` - Jido agent with signal routing for Amp sessions
- `Jido.Amp.Signal` - typed custom signal modules/builders
- `Jido.Amp.Actions.StartSession` - spawns stream runner
- `Jido.Amp.Actions.HandleMessage` - maps SDK stream messages to signals/state
- `Jido.Amp.StreamRunner` - enumerates stream and dispatches internal messages
- `Jido.Amp.Threads|Tools|Permissions|MCP|Tasks|Review|Skills` - full namespaced wrappers
- Mix tasks:
  - `mix amp.install`
  - `mix amp.compat`
  - `mix amp.thread`

## Design Rules

1. Stability first
- `Jido.Amp.run/2` and `Jido.Amp.execute/2` must fail fast on incompatible Amp CLI.
- Do not silently fallback to non-streaming behavior in these APIs.

2. Curated top-level API
- Keep `Jido.Amp` focused on common operations.
- Expose broader Amp SDK parity through namespaced modules.

3. Signal model
- Use typed `Jido.Signal` modules under `Jido.Amp.Signal`.
- Route `"amp.session.start"` and `"amp.internal.message"` in `Jido.Amp.Agent`.

4. Validation and errors
- Use Zoi for structured options validation.
- Use `Jido.Amp.Error` (`Splode`) for structured errors.

5. Testability
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
- Never include `ampcode` as a contributor/co-author
