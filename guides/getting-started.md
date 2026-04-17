# Getting Started with Jido.Amp

This guide covers adapter-focused `Jido.Amp` flows:
- Compatibility checks
- Blocking and streaming execution

## 1. Install and Verify

Add dependencies:

```elixir
defp deps do
  [
    {:jido_harness, github: "agentjido/jido_harness", branch: "main", override: true},
    {:jido_amp, github: "agentjido/jido_amp", branch: "main"}
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

## 3. Test and Quality

```bash
mix test
mix quality
```

Integration tests are opt-in (`@tag :integration`) and excluded from default test runs.
