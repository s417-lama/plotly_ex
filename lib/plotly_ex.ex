defmodule PlotlyEx do
  alias PlotlyEx.OneTimeServer

  @root_path File.cwd!()

  def plot(data, layout \\ %{}) do
    json_data   = Jason.encode!(data)
    json_layout = Jason.encode!(layout)
    filepath    = Path.join([@root_path, "templates", "plot_region.html.eex"])
    EEx.eval_file(filepath, data: json_data, layout: json_layout)
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

  defp show_html(plot_body) do
    filepath = Path.join([@root_path, "templates", "show_page.html.eex"])
    EEx.eval_file(filepath, plot_body: plot_body)
  end

  defp open(filename) do
    "open #{filename} || xdg-open #{filename}"
    |> to_charlist()
    |> :os.cmd()
  end
end
