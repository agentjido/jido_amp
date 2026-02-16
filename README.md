# Jido.Amp

`Jido.Amp` integrates the Amp CLI SDK (`amp_sdk`) with Jido.

It provides:
- Fail-fast streaming compatibility checks for `amp_sdk` (`--execute --stream-json`)
- A Jido agent (`Jido.Amp.Agent`) for Amp session lifecycle and stream signal routing
- A curated top-level API in `Jido.Amp`
- Full Amp management parity via namespaced modules (`Jido.Amp.Threads`, `Jido.Amp.Tools`, etc.)
- Mix tasks for install/compatibility/thread execution

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
- Amp CLI support for streaming flags required by `amp_sdk`:
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

## Agent Runtime

`Jido.Amp.Agent` routes:
- `"amp.session.start"` -> `Jido.Amp.Actions.StartSession`
- `"amp.internal.message"` -> `Jido.Amp.Actions.HandleMessage`

Example session start signal:

```elixir
signal = Jido.Amp.Signal.session_start("Fix this bug", cwd: "/path/to/project")
```

Emitted session/turn signals include:
- `amp.session.started`
- `amp.turn.text`
- `amp.turn.thinking`
- `amp.turn.tool_use`
- `amp.turn.tool_result`
- `amp.session.completed`
- `amp.session.error`

## API Layout

Curated top-level API (`Jido.Amp`):
- `run/2`, `execute/2`
- `threads_list/1`, `threads_search/2`, `threads_markdown/1`
- `tools_list/0`
- `permissions_list/1`
- `mcp_list/1`
- `usage/0`

Full management API (namespaced):
- `Jido.Amp.Threads`
- `Jido.Amp.Tools`
- `Jido.Amp.Permissions`
- `Jido.Amp.MCP`
- `Jido.Amp.Tasks`
- `Jido.Amp.Review`
- `Jido.Amp.Skills`

## Mix Tasks

- `mix amp.install` - check CLI install and print setup guidance
- `mix amp.compat` - validate streaming compatibility
- `mix amp.thread THREAD_ID "PROMPT" [options]` - execute directly against an existing thread

## Development

```bash
mix test
mix quality
```

See `guides/getting-started.md` for a complete usage walkthrough.
