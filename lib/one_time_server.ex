defmodule PlotlyEx.OneTimeServer do
  def start() do
    {:ok, socket} = :gen_tcp.listen(0, [:binary, packet: :http_bin, active: false, reuseaddr: true])
    {:ok, port  } = :inet.port(socket)
    IO.puts(:stderr, "listening on http://localhost:#{port}")
    {port, socket}
  end

  def response(socket, html) do
    {:ok, request} = :gen_tcp.accept(socket)
    :gen_tcp.send(request, """
    HTTP/1.1 200
    Content-Type: text/html
    Content-Length: #{byte_size(html)}

    #{html}
    """)
    :gen_tcp.close(request)
    :gen_tcp.close(socket)
    IO.puts(:stderr, "quitting...")
  end
end
