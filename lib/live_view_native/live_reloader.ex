defmodule LiveViewNative.LiveReloader do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    conn
    |> get_format()
    |> LiveViewNative.fetch_plugin()
    |> case do
      {:ok, _plugin} -> live_reload(conn)
      :error -> conn
    end
  end

  defp get_format(%Plug.Conn{query_string: query_string}) do
    URI.decode_query(query_string)["_format"]
  end

  defp live_reload(conn) do
    endpoint = conn.private.phoenix_endpoint
    config = endpoint.config(:live_reload)
    patterns = config[:patterns]

    if patterns && patterns != [] do
      before_send_inject_reloader(conn, endpoint, config)
    else
      conn
    end
  end

  defp before_send_inject_reloader(conn, endpoint, config) do
    register_before_send(conn, fn conn ->
      if conn.resp_body != nil do
        resp_body = IO.iodata_to_binary(conn.resp_body)

        if :code.is_loaded(endpoint) do
          body = resp_body <> reload_assets_tag(conn, endpoint, config)
          put_in(conn.resp_body, body)
        else
          conn
        end
      else
        conn
      end
    end)
  end

  defp reload_assets_tag(conn, endpoint, config) do
    path = conn.private.phoenix_endpoint.path("/phoenix/live_reload/frame#{suffix(endpoint)}")

    attrs =
      Keyword.merge(
        [hidden: true, height: 0, width: 0, src: path],
        Keyword.get(config, :iframe_attrs, [])
      )

    attrs =
      if Keyword.has_key?(config, :iframe_class) do
        IO.warn(
          "The :iframe_class for Phoenix LiveReloader is deprecated, " <>
            "please remove it or use :iframe_attrs instead"
        )

        Keyword.put_new(attrs, :class, config[:iframe_class])
      else
        attrs
      end

    IO.iodata_to_binary(["<iframe", attrs(attrs), "></iframe>"])
  end

  defp attrs(attrs) do
    Enum.map(attrs, fn
      {_key, nil} -> []
      {_key, false} -> []
      {key, true} -> [?\s, key(key)]
      {key, value} -> [?\s, key(key), ?=, ?", value(value), ?"]
    end)
  end

  defp key(key) do
    key
    |> to_string()
    |> String.replace("_", "-")
    |> Plug.HTML.html_escape_to_iodata()
  end

  defp value(value) do
    value
    |> to_string()
    |> Plug.HTML.html_escape_to_iodata()
  end

  defp suffix(endpoint), do: endpoint.config(:live_reload)[:suffix] || ""
end
