defmodule PlotlyEx.OneTimeServer do
  def start() do
    {:ok, socket} = :gen_tcp.listen(0, active: false)
    {:ok, port  } = :inet.port(socket)
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
  end
end
