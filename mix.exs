defmodule ElixirCqrsEsExample.Mixfile do
  use Mix.Project

  def project do
    [
      app: :elixir_cqrs_es_example,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Bank, []}
    ]
  end

  defp deps do
    [
      {:mox, "~> 0.4", only: :test},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
