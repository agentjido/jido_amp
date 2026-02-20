# Jido.Amp

`Jido.Amp` is an Amp CLI adapter package for `Jido.Harness`.

It provides:
- Fail-fast streaming compatibility checks for `amp_sdk` (`--execute --stream-json`)
- Adapter-focused execution APIs (`run/2`, `execute/2`)
- Runtime diagnostics tasks (`mix amp.install`, `mix amp.compat`)

## Installation

```elixir
defp deps do
  [
    {:jido_amp, "~> 0.1.0"}
  ]
end
```

Then:

```bash
mix deps.get
```

## Requirements

- Elixir `~> 1.18`
- Amp CLI installed and authenticated
- Amp CLI support for:
  - `--execute`
  - `--stream-json`

## Quick Start

### 1) Verify CLI setup

```bash
mix amp.install
mix amp.compat
```

### 2) Run a prompt (blocking)

```elixir
{:ok, result} =
  Jido.Amp.run("Summarize the failing tests and propose a fix", cwd: "/path/to/project")
```

### 3) Stream messages

```elixir
Jido.Amp.execute("Refactor this module", cwd: "/path/to/project")
|> Enum.each(&IO.inspect/1)
```

## Mix Tasks

- `mix amp.install` - check/install Amp CLI deterministically
- `mix amp.compat` - validate streaming compatibility

## Development

```bash
mix test
mix quality
```

See `guides/getting-started.md` for walkthrough details.
