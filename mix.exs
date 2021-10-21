defmodule ElixirCachingValidere.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_caching_validere,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ElixirCachingValidere.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.2"},
      {:poison, "~> 4.0.1"},
      {:poolboy, "~> 1.5"},
      {:credo, "~> 1.3", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21.3", only: :dev, runtime: false},
      {:excoveralls, "~> 0.12.3", only: :test}
    ]
  end
end
