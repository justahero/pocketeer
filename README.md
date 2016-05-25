# Pocketeer

A client library for the [Pocket API (v3)](https://getpocket.com/developer/docs/overview)  written in Elixir. The library supports the [Add](https://getpocket.com/developer/docs/v3/add), [Modify](https://getpocket.com/developer/docs/v3/modify) and [Retrieve](https://getpocket.com/developer/docs/v3/retrieve) endpoints of the Pocket API. It also supports modifying mulitple items at once in a bulk operation.

If you want to picture how Pocketeer looks, [Pixar](http://pixar.wikia.com/wiki/Pocketeer) did a very good job.

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

## Authentication

To use the Pocket API, first the authentication process needs to be done, by using the consumer key to retrieve an access token. Both are required to use the API.

For this your application needs to be registered on the [Pocket Developers page](https://getpocket.com/developer/apps/new). Once the application is registered the consumer key is displayed on the [My Applications](https://getpocket.com/developer/apps/) page. For more details check the [Authorization process](https://getpocket.com/developer/docs/authentication) on Pocket.

Your application should offer a page where users are redirected to after confirming or declining the authorization request by Pocket.

The following steps show how to use the consumer key to get an access token.

  1. Fetch `request_token` from Pocket.

    ```elixir
    {:ok, body} = Pocketeer.Auth.get_request_token(consumer_key, "http://yoursite.com")
    #=> {:ok, %{"code" => "abcd", "state" => nil}}
    request_token = body["code"]
    #=> "abcd"
    ```

  2. With this token, redirect the user to the authorization page of your application.

    ```elixir
    # a helper function can be used to construct the url.
    Pocketeer.Auth.authorize_url("abcd", "http://yoursite.com")
    #=> "https://getpocket.com/v3/oauth/authorize?request_token=abcd&redirect_uri=http%3A%2F%2Fyoursite.com"
    ```

  3. Get an `access_token` after the user accepts the authorization.

    ```elixir
    {:ok, body} = Pocketeer.Auth.get_access_token(consumer_key, request_token)
    #=> {:ok, %{"access_token" => "efgh", "username" => "pocketuser"}}
    access_token = body["access_token"]
    #=> "egfh"
    ```

For more detailed handling of the requests above:

```elixir
response = Pocketeer.Auth.get_request_token(consumer_key, "http://yoursite.com")
case response do
  {:ok, body}     -> body["code"]
  {:error, error} -> IO.puts "Error: #{error.message}"
end
```