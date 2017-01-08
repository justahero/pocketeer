# Pocketeer

[![Build Status](https://travis-ci.org/justahero/pocketeer.svg?branch=master)](https://travis-ci.org/justahero/pocketeer)

A client library for the [getpocket.com](https://getpocket.com) service written in Elixir. The library supports all endpoints of the Pocket API. It also supports modifying mulitple items in a bulk operation.

If you want to picture how Pocketeer might look, [Pixar's character](http://pixar.wikia.com/wiki/Pocketeer) with the same name from the short movie [Toy Story Of Terror!](http://pixar.wikia.com/wiki/Toy_Story_of_Terror!) is a really good fit.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add pocketeer to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:pocketeer, "~> 0.1.4"}]
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

For more detailed handling of the request above:

```elixir
response = Pocketeer.Auth.get_request_token(consumer_key, "http://yoursite.com")
case response do
  {:ok, body}     -> body["code"]
  {:error, error} -> IO.puts "Error: #{error.message}"
end
```

## Usage

Once the `consumer_key` and `access_token` are available, the API offers different functions, categorized into
[Add](https://getpocket.com/developer/docs/v3/add), [Modify](https://getpocket.com/developer/docs/v3/modify) and [Retrieve](https://getpocket.com/developer/docs/v3/retrieve).

To save a new item in Pocket:

```elixir
# with url
Pocketeer.add(client, %{url: "http://example.com", title: "Test", tags: ["news", "test"]})
%{:ok, %{"item" => { ... }}}
# with existing item id
Pocketeer.add(client, %{item_id: "1234", title: "Saved before", tweet_id: "tweet_id"})
%{:ok, %{"item" => { ... }}}
```

To fetch the list of the last 10 oldest favorited videos.

```elixir
options = Pocketeer.Get.new(%{sort: :oldest, count: 10, contentType: :video, favorite: true})
{:ok, response} = Pocketeer.get(client, options)
```

To delete an item and also add tags to another item, executed in a bulk operation

```elixir
Item.new
|> Item.delete("1234")
|> Item.tags_add("4444", ["great", "stuff"])
|> Pocketeer.post(client)
{:ok, %{"action_results" => [true, true], "status" => 1}}
```

## Other libraries

There are other libraries out there worth checking out:

* [pocketex](https://github.com/essenciary/pocketex)


## Licene

This software is licensed under [MIT License](https://github.com/justahero/pocketeer/blob/master/LICENSE.md).