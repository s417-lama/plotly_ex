defmodule PlotlyEx do
  alias PlotlyEx.OneTimeServer

  def plot(data) do
    json_data = Jason.encode!(data)
    """
    <div class="plotly-ex">
      <div id="plotly-ex-body"></div>
      <script>
        var d3 = Plotly.d3
        var img_svg = d3.select('#svg-export')
        var data = #{json_data}
        Plotly.plot('plotly-ex-body', data)
      </script>
    </div>
    """
  end

  def show(plot_html, opts \\ []) do
    show_html = show_html(plot_html)
    case Keyword.get(opts, :filename) do
      nil ->
        {port, socket} = OneTimeServer.start()
        open("http://localhost:#{port}")
        OneTimeServer.response(socket, show_html)
      filename ->
        File.write(filename, show_html)
        open(filename)
    end
  end

  defp show_html(plot_html) do
    """
    <head>
      <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
    </head>

    <body>
      #{plot_html}
      <button id="plotly-ex-save-button">Save as SVG</button>
      <a id="plotly-ex-download-link" download="test2.svg" style="display:none;" />
      <script>
        document.getElementById("plotly-ex-save-button").onclick = () => {
          let graph_body   = document.getElementById('plotly-ex-body')
          let graph_width  = graph_body.clientWidth
          let graph_height = graph_body.clientHeight
          Plotly.toImage(graph_body, {format: 'svg', width: graph_width, height: graph_height})
          .then((url) => {
            let download_link = document.getElementById("plotly-ex-download-link")
            download_link.href = url
            download_link.click()
          })
        }
      </script>
    </body>
    """
  end

  defp open(filename) do
    "open #{filename} || xdg-open #{filename}"
    |> to_charlist()
    |> :os.cmd()
  end
end
