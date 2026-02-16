# Getting Started with Jido.Amp

This guide covers the main `Jido.Amp` flows:
- Compatibility checks
- Blocking and streaming execution
- Agent/session signal flow
- Thread execution from CLI

## 1. Install and Verify

Add dependency:

```elixir
defp deps do
  [
    {:jido_amp, "~> 0.1.0"}
  ]
end
```

Fetch deps:

```bash
mix deps.get
```

Verify Amp CLI and compatibility:

```bash
mix amp.install
mix amp.compat
```

## 2. Run Prompts

Blocking:

```elixir
{:ok, result} = Jido.Amp.run("Explain why tests are failing", cwd: "/repo")
```

Streaming:

```elixir
Jido.Amp.execute("Fix these tests", cwd: "/repo")
|> Enum.each(&IO.inspect/1)
```

If compatibility fails, `run/2` returns a config error and `execute/2` raises `Jido.Amp.Error.ConfigError`.

## 3. Work with Threads and Management APIs

Curated top-level operations:

```elixir
{:ok, threads} = Jido.Amp.threads_list(limit: 20)
{:ok, markdown} = Jido.Amp.threads_markdown("th_123")
```

Advanced operations via namespaced modules:

```elixir
{:ok, _} = Jido.Amp.Threads.rename("th_123", "New title")
{:ok, _} = Jido.Amp.Tools.show("Read")
{:ok, _} = Jido.Amp.Permissions.add("Read", "allow", to: "workspace")
{:ok, _} = Jido.Amp.MCP.list()
{:ok, _} = Jido.Amp.Tasks.list()
{:ok, _} = Jido.Amp.Review.run()
{:ok, _} = Jido.Amp.Skills.list()
```

## 4. Use the Agent Runtime

`Jido.Amp.Agent` handles an Amp session lifecycle with typed signals.

Start signal:

```elixir
signal = Jido.Amp.Signal.session_start("Refactor this file", cwd: "/repo")
```

Key emitted signals:
- `amp.session.started`
- `amp.turn.text`
- `amp.turn.thinking`
- `amp.turn.tool_use`
- `amp.turn.tool_result`
- `amp.session.completed`
- `amp.session.error`

## 5. Run Against an Existing Thread from CLI

```bash
mix amp.thread THREAD_ID "Continue with a fix" --cwd /repo --timeout 120000
```

This uses direct CLI execution mode and remains available even when streaming compatibility is unresolved.

## 6. Test and Quality

```bash
mix test
mix quality
```

Integration tests are opt-in (`@tag :integration`) and excluded from default test runs.
