# Change Log

## [Unreleased]

## [0.2.0] - 2016-07-31

Improve Pocket get response, fills struct

* extend `Response` struct and fill `articles` property with list of fetched articles from Pocket
* fix return type from Pocketeer functions `Response` struct
* adjust tests accordingly

The response type for the Pocketeer functions is now the `Pocketeer.Response` struct. This matches and fixes the documented type specification.

```elixir
{:ok, response} = Pocketeer.Get(client, %{})
response.body       # to access the parsed JSON response
response.articles   # to access the list of fetched articles
```


## [0.1.2] - 2016-07-10

A few things were fixed

* add test to check behaviour when user denies auth request with Pocket
* add support for Travis CI builds
* fix type specification of `Pocketeer.get!` method
* update lib dependencies

**Note** the release was tagged later on Github


## [0.1.1] - 2016-05-28

* fix GET request when `state` not given


## [0.1.0] - 2016-05-28

Initial release of lib

* support for authentication
* support for all API endpoints
