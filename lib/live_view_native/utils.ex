defmodule LiveViewNative.Utils do
  alias Phoenix.LiveView.Socket

  def get_format(%Socket{private: %{connect_info: %{private: %{phoenix_format: format}}}}), do: format
  def get_format(%Socket{private: %{connect_params: %{_phoenix_format: format}}}), do: format
  def get_format(_socket), do: "html"

  def get_target(%Socket{private: %{connect_info: %{params: %{"target" => target}}}}), do: target
  def get_target(_socket), do: nil

  def normalize_format(format) when is_binary(format), do: format
  def normalize_format(format) when is_atom(format), do: Atom.to_string(format)
end