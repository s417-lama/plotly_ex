defmodule PlotlyEx do
  alias PlotlyEx.OneTimeServer

  @root_path File.cwd!()

  def plot(data, layout \\ %{}, config \\ %{}) do
    filepath    = Path.join([@root_path, "templates", "plot_region.html.eex"])
    json_data   = Jason.encode!(data)
    json_layout = Jason.encode!(layout)
    json_config = Jason.encode!(config)
    unique_id   = :erlang.unique_integer([:positive])
    EEx.eval_file(filepath, data: json_data, layout: json_layout, config: json_config, id: unique_id)
  end

  def show(plot_html, opts \\ []) do
    plotly_js_url =
      case Keyword.get(opts, :plotly_js_url) do
        nil -> "https://cdn.plot.ly/plotly-latest.min.js"
        url -> url
      end
    mathjax_js_url =
      case Keyword.get(opts, :mathjax_js_url) do
        nil -> "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-AMS-MML_SVG"
        url -> url
      end
    show_html = show_html(plot_html, plotly_js_url, mathjax_js_url)
    case Keyword.get(opts, :filename) do
      nil ->
        {port, socket} = OneTimeServer.start()
        open("http://localhost:#{port}")
        OneTimeServer.response(socket, show_html)
      filename ->
        File.write(filename, show_html)
        open(filename)
    end
    :ok
  end

  defp show_html(plot_body, plotly_js_url, mathjax_js_url) do
    filepath = Path.join([@root_path, "templates", "show_page.html.eex"])
    EEx.eval_file(filepath, plot_body: plot_body, plotly_js_url: plotly_js_url, mathjax_js_url: mathjax_js_url)
  end

  defp open(filename) do
    "open #{filename} || xdg-open #{filename}"
    |> to_charlist()
    |> :os.cmd()
  end
end
