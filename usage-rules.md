# Jido.Amp Usage Rules for Coding Agents

This file captures implementation constraints and expected patterns.

## Runtime Compatibility

- `Jido.Amp.run/2` and `Jido.Amp.execute/2` require Amp CLI streaming compatibility.
- Required CLI help flags: `--execute`, `--stream-json`.
- Use `Jido.Amp.Compatibility.check/0` or `mix amp.compat`.
- Do not add implicit fallback behavior in `run/2` or `execute/2`.

## API Surface

- Keep `Jido.Amp` curated.
- Expose advanced operations via namespaced modules:
  - `Jido.Amp.Threads`
  - `Jido.Amp.Tools`
  - `Jido.Amp.Permissions`
  - `Jido.Amp.MCP`
  - `Jido.Amp.Tasks`
  - `Jido.Amp.Review`
  - `Jido.Amp.Skills`

## Signal Model

- Use `Jido.Amp.Signal` custom typed signals.
- Required routing in `Jido.Amp.Agent.signal_routes/1`:
  - `"amp.session.start"` -> `Jido.Amp.Actions.StartSession`
  - `"amp.internal.message"` -> `Jido.Amp.Actions.HandleMessage`
- Preserve support for existing signal types while extending behavior.

## Validation and Errors

- Use Zoi for schema validation (`Jido.Amp.Options`).
- Use `Jido.Amp.Error` (`Splode`) for structured runtime/config errors.
- Return `{:ok, value}` / `{:error, reason}` unless raising is explicitly part of API contract.

## Testing

- Coverage must remain >=90%.
- Unit-test wrappers/delegates and compatibility logic with injected stubs.
- Keep live CLI/account tests tagged as `@tag :integration` and opt-in.

## Tooling and Quality

Required checks:

```bash
mix compile --warnings-as-errors
mix test
mix credo --strict
mix doctor --raise
```

## Dependency and Packaging

- No `jido_dep/4` helper.
- Keep package metadata (`README`, guides, changelog, package file list) consistent with shipped modules.
- Keep CI workflows aligned with project quality gates.
