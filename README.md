# Pocketeer

A client library for the Pocket API written in Elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add pocketeer to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:pocketeer, "~> 0.0.1"}]
    end
    ```

  2. Ensure pocketeer is started before your application:

    ```elixir
    def application do
      [applications: [:pocketeer]]
    end
    ```

## Usage

To use the client, first a consumer key is necessary. For this your application needs to be registered on the [Pocket Developers page](https://getpocket.com/developer/apps/new).
Once the application is registered the consumer key is displayed on the [My Applications](https://getpocket.com/developer/apps/) page.

To use the client, first it's necessary to authorize the application. For more details check the [Authorization process](https://getpocket.com/developer/docs/authentication) on Pocket.

  1. Fetch a request token from Pocket

    ```elixir
    iex> {:ok, body} = Pocketeer.Auth.get_request_token(consumer_key, "http://yoursite.com")
    {:ok, %{"code" => "abcd", "state" => nil}}
    iex> request_token = body["code"]
    "abcd"
    ```

  2. Once the user receives the request token, redirect the user to the authorization page.
     The user might accept or decline the authorization request on Pocket.

    ```elixir
    # a helper function can be used to construct the url.
    iex> Pocketeer.Auth.authorize_url("abcd", "http://yoursite.com")
    "https://getpocket.com/v3/oauth/authorize?request_token=abcd&redirect_uri=http%3A%2F%2Fyoursite.com"
    ```

  3. Get an access token after the user accepts the authorization.

    ```elixir
    iex> Pocketeer.Auth.get_access_token(consumer_key, request_token)
    {:ok, %{"access_token" => "efgh", "username" => "pocketuser"}}
    ```
