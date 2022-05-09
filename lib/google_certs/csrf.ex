defmodule GoogleCerts.CSRF do
  # Checks that the g_crsf_token in the POST body and cookie are present and are equal
  def verify_csrf(conn, params) do
    with {true, csrf_token_body} <- csrf_token_in_body?(conn, params),
         {true, csrf_token_cookie} <- csrf_token_in_cookie?(conn, params),
         {true, csrf_token} <- csrf_tokens_equal?(csrf_token_body, csrf_token_cookie) do
      {:ok, csrf_token}
    else
      {false, reason} -> {:error, reason}
    end
  end

  defp csrf_token_in_body?(_conn, params) do
    token = params["g_csrf_token"]

    if token do
      {true, token}
    else
      {false, "CSRF token not found in post body"}
    end
  end

  defp csrf_token_in_cookie?(conn, _params) do
    token = conn.cookies["g_csrf_token"]

    if token do
      {true, token}
    else
      {false, "CSRF token not found in cookies"}
    end
  end

  defp csrf_tokens_equal?(body_token, cookie_token) do
    if body_token == cookie_token do
      {true, body_token}
    else
      {false, "CSRF token in body and cookie do not match"}
    end
  end
end
