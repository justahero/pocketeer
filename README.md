# Pocketeer

A client library for the Pocket API written in Elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add pocketeer to your list of dependencies in `mix.exs`:

        def deps do
          [{:pocketeer, "~> 0.0.1"}]
        end

  2. Ensure pocketeer is started before your application:

        def application do
          [applications: [:pocketeer]]
        end


## Usage

To use the client, first a consumer key is necessary. For this your application needs to be registered on the [Pocket Developers page](https://getpocket.com/developer/apps/new).
Once the application is registered the consumer key is displayed on the [My Applications](https://getpocket.com/developer/apps/) page.

To use the client, first it's necessary to authorize the application. For more details check the [Authorization process](https://getpocket.com/developer/docs/authentication) on Pocket.

First a request token is fetched from Pocket

```elixir
iex> {:ok, code} = Pocketeer.Auth.get_request_token(consumer_key, "http://yoursite.com")
{:ok, {code: "abcd"}}
```

Once the user receives the request token, redirect the user to authorization page.
A helper function can be used to get the right url.

```elixir
iex> Pocketeer.Auth.authorize_url("abcd", "http://yoursite.com")
"https://getpocket.com/v3/oauth/authorize?request_token=abcd&redirect_uri=http%3A%2F%2Fyoursite.com"
```

When the user accepts or declines the request Pocket redirect to the given url. The last step is to fetch an access token.

```elixir
iex> {code: request_token} = code
iex> Pocketeer.Auth.get_access_token(consumer_key, request_token)
{:ok, {code: "access_token"}}
```
