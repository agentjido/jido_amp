defmodule JidoAmp.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/agentjido/jido_amp"
  @description "Amplified AI orchestration for the Jido ecosystem"

  def project do
    [
      app: :jido_amp,
      version: @version,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      # Documentation
      name: "Jido.Amp",
      source_url: @source_url,
      homepage_url: @source_url,
      docs: [
        main: "Jido.Amp",
        extras: ["README.md", "CHANGELOG.md", "guides/getting-started.md"],
        formatters: ["html"]
      ],
      # Hex packaging
      package: [
        name: :jido_amp,
        licenses: ["Apache-2.0"],
        links: %{"GitHub" => @source_url}
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Jido.Amp.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Core ecosystem
      {:zoi, "~> 0.16"},
      {:splode, "~> 0.3"},
      {:req_llm, github: "agentjido/req_llm", branch: "main"},
      {:amp_sdk, github: "nshkrdotcom/amp_sdk", branch: "master"},

      # Dev/Test
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:doctor, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18", only: [:dev, :test]},
      {:git_hooks, "~> 0.8", only: [:dev, :test], runtime: false},
      {:git_ops, "~> 2.9", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"],
      quality: [
        "compile",
        "format --check-formatted",
        "credo --strict",
        "dialyzer",
        "doctor --raise"
      ],
      test: ["test --cover --color"],
      "test.watch": ["watch -c \"mix test\""]
    ]
  end
end
