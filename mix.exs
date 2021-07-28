defmodule Jqish.Mixfile do
  use Mix.Project

  def project do
    [
      app: :jqish,
      version: "0.2.0",
      elixir: "~> 1.5",
      package: package(),
      description: description(),
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end


  defp description do
    """
      Jq like thing for grabbing stuff out of json like objects
    """
  end

  defp package do
    [
      maintainers: ["Chris Duranti"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/rozap/jqish"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
