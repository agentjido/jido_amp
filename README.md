# Jido.Amp

> [!WARNING]
> **Deprecated.** This repository is no longer maintained and is retained as a
> read-only archive. Amp support now lives directly in
> [Jido Harness](https://github.com/agentjido/jido_harness). Use `jido_harness`
> for new development.

[![Hex.pm](https://img.shields.io/hexpm/v/jido_amp.svg)](https://hex.pm/packages/jido_amp)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/jido_amp/)
[![CI](https://github.com/agentjido/jido_amp/actions/workflows/ci.yml/badge.svg)](https://github.com/agentjido/jido_amp/actions/workflows/ci.yml)
[![License](https://img.shields.io/hexpm/l/jido_amp.svg)](https://github.com/agentjido/jido_amp/blob/main/LICENSE)
[![Website](https://img.shields.io/badge/website-jido.run-0f172a.svg)](https://jido.run)
[![Ecosystem](https://img.shields.io/badge/ecosystem-jido.run-0ea5e9.svg)](https://jido.run/ecosystem)
[![Discord](https://img.shields.io/badge/discord-join-5865F2.svg?logo=discord&logoColor=white)](https://jido.run/discord)

`Jido.Amp` is an Amp CLI adapter package for `Jido.Harness`.

It provides:
- Fail-fast streaming compatibility checks for `amp_sdk` (`--execute --stream-json`)
- Adapter-focused execution APIs (`run/2`, `execute/2`)
- Runtime diagnostics tasks (`mix amp.install`, `mix amp.compat`)

## Installation

```elixir
defp deps do
  [
    {:jido_harness, github: "agentjido/jido_harness", branch: "main", override: true},
    {:jido_amp, github: "agentjido/jido_amp", branch: "main"}
  ]
end
```

This repo is currently aligned as part of the GitHub-based harness package set rather than a Hex release line.

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

## Package Purpose

`jido_amp` is the Amp CLI adapter for `jido_harness`, focused on normalized event mapping and adapter/runtime contract compatibility.

## Testing Paths

- Unit/contract tests: `mix test`
- Full quality gate: `mix quality`
- Optional live checks: `mix amp.install && mix amp.compat`

## Live Integration Tests

`jido_amp` includes opt-in live tests that run the real Amp CLI through both the compatibility probe and the harness adapter path:

```bash
mix test --include integration test/jido_amp/integration/compatibility_integration_test.exs
mix test --include integration test/jido_amp/integration/adapter_live_integration_test.exs
```

The tests auto-load `.env` and are excluded from default `mix test` runs.

Environment knobs:

- `AMP_API_KEY` when using env-based Amp auth
- `JIDO_AMP_LIVE_PROMPT` to override the default prompt
- `JIDO_AMP_LIVE_CWD` to override the working directory
- `JIDO_AMP_LIVE_TIMEOUT_MS` to extend the per-run timeout
- `JIDO_AMP_REQUIRE_SUCCESS=1` to fail unless the terminal event is successful
- `JIDO_AMP_CLI_PATH` to target a non-default Amp CLI binary
