defmodule PlotlyEx do
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

  def show(plot_html) do
    filename = Path.join(tmp_dir(), "plot.html")
    File.write(filename, """
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
    """)
    open(filename)
  end

  defp tmp_dir() do
    {dir, 0} = System.cmd("mktemp", ["-d"])
    String.trim(dir)
  end

  defp open(filename) do
    open_impl(["open", "xdg-open"], filename)
  end

  defp open_impl([]          , filename), do: {:error, "opening #{filename} failed"}
  defp open_impl([cmd | rest], filename) do
    case System.cmd(cmd, [filename], stderr_to_stdout: true) do
      {_, 0} -> :ok
      _      -> open_impl(rest, filename)
    end
  end
end
