defmodule UQuery.MixProject do
  use Mix.Project

  @source_url "https://github.com/adilsonchacon/uquery"
  @version "0.1.0"

  def project do
    [
      app: :uquery,
      name: "UQuery",
      version: @version,
      source_url: @source_url,
      description: description(),
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:ecto, "~> 3.10"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0", only: :test},
      {:mox, "~> 1.0", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp description() do
    "UQuery centralizes reusable queries, e.g. for pagination and counting rows."
  end

  defp package() do
    [
      name: "UQuery",
      files: ~w(lib mix.exs README.md LICENSE config),
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
