defmodule StopUnwantedCalls.Mixfile do
  use Mix.Project

  def project do
    [
      app: :stop_unwanted_calls,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {StopUnwantedCalls.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:event_socket_outbound, "~> 0.3.0"},
      {:httpoison, "~> 1.0"},
      {:poison, "~> 3.1"},
      # release stuff
      {:distillery, "~> 1.5"},
      {:conform, "~> 2.5"},
      # devel stuff
      {:credo, "~> 0.8", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.8.0", only: :test}
    ]
  end
end
