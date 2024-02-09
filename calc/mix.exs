defmodule Calc.MixProject do
  use Mix.Project

  def project do
    [
      app: :calc,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:recon_ex, github: "liberlanco/recon_ex"}
    ]
  end
end
