defmodule PlotlyEx.OneTimeServer do
  @timeout 60_000

  def start() do
    {:ok, socket} = :gen_tcp.listen(0, [:binary, packet: :http_bin, active: false, reuseaddr: true])
    {:ok, port  } = :inet.port(socket)
    IO.puts(:stderr, "listening on http://localhost:#{port}")
    {port, socket}
  end

  def response(socket, html) do
    case :gen_tcp.accept(socket, @timeout) do
      {:ok, request} ->
        {:ok, _} = :gen_tcp.recv(request, 0)
        :gen_tcp.send(request, """
        HTTP/1.1 200
        Content-Type: text/html
        Content-Length: #{byte_size(html)}

        #{html}
        """)
        :gen_tcp.close(request)
        :gen_tcp.close(socket)
        IO.puts(:stderr, "accepted. quitting...")
      {:error, :timeout} ->
        IO.puts(:stderr, "timeout. quitting...")
    end
  end
end
