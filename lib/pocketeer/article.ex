defmodule Pocketeer.Article do
  @moduledoc """
  Constructs a response result to hold an Pocket article.
  """

  defmodule Image do
    @type item_id  :: binary
    @type image_id :: binary
    @type src      :: binary
    @type width    :: binary
    @type height   :: binary
    @type credit   :: binary
    @type caption  :: binary

    @type t :: %__MODULE__{
      item_id:  item_id,
      image_id: image_id,
      src:      src,
      width:    width,
      height:   height,
      credit:   credit,
      caption:  caption
    }

    defstruct item_id: nil,
              image_id: nil,
              src: nil,
              width: "0",
              height: "0",
              credit: nil,
              caption: ""

    @spec new(map) :: t
    def new(options) do
      struct(__MODULE__, options)
    end
  end

  defmodule Video do
    @type item_id  :: binary
    @type video_id :: binary
    @type src      :: binary
    @type width    :: binary
    @type height   :: binary
    @type type     :: binary
    @type vid      :: binary

    @type t :: %__MODULE__{
      item_id:  item_id,
      video_id: video_id,
      src:      src,
      width:    width,
      height:   height,
      type:     type,
      vid:      vid
    }

    defstruct item_id: nil,
              video_id: nil,
              src: nil,
              width: "0",
              height: "0",
              type: "1",
              vid: nil

    @spec new(map) :: t
    def new(options) do
      struct(__MODULE__, options)
    end
  end

  @type item_id        :: binary
  @type resolved_id    :: binary
  @type given_url      :: binary
  @type given_title    :: binary
  @type favorite       :: binary
  @type status         :: binary
  @type resolved_title :: binary
  @type resolved_url   :: binary
  @type excerpt        :: binary
  @type is_article     :: binary
  @type has_image      :: binary
  @type has_video      :: binary
  @type word_count     :: binary
  @type tags           :: [String.t]
  @type authors        :: [String.t]
  @type images         :: [Image.t]
  @type videos         :: [Video.t]
  @type time_added     :: Date.t
  @type time_favorited :: Date.t
  @type time_read      :: Date.t
  @type time_updated   :: Date.t

  @type t :: %__MODULE__{
    item_id:        item_id,
    resolved_id:    resolved_id,
    given_url:      given_url,
    given_title:    given_title,
    favorite:       favorite,
    status:         status,
    resolved_title: resolved_title,
    resolved_url:   resolved_url,
    excerpt:        excerpt,
    is_article:     is_article,
    has_image:      has_image,
    has_video:      has_video,
    word_count:     word_count,
    tags:           tags,
    authors:        authors,
    images:         images,
    videos:         videos,
    time_added:     time_added,
    time_favorited: time_favorited,
    time_read:      time_read,
    time_updated:   time_updated
  }

  defstruct item_id: nil,
            resolved_id: nil,
            given_url: nil,
            given_title: nil,
            favorite: nil,
            status: nil,
            resolved_title: nil,
            resolved_url: nil,
            excerpt: "",
            is_article: "1",
            has_image: "0",
            has_video: "0",
            word_count: "0",
            tags: [],
            authors: [],
            images: [],
            videos: [],
            time_added: nil,
            time_favorited: nil,
            time_read: nil,
            time_updated: nil

  @spec new(map) :: t
  def new(options) do
    struct(__MODULE__, options |> to_atom_keys |> parse_arrays)
  end

  defp parse_arrays(options) do
    options
    |> parse_images()
    |> parse_videos()
  end

  defp parse_images(%{} = options) do
    Map.update(options, :images, [], fn images ->
      Enum.map(images, fn {_key, image} -> Image.new(image) end)
    end)
  end

  defp parse_videos(%{} = options) do
    Map.update(options, :videos, [], fn videos ->
      Enum.map(videos, fn {_key, video} -> Video.new(video) end)
    end)
  end

  defp to_atom_keys(options) do
    options |> Enum.reduce(%{}, fn ({key, val}, acc) -> Map.put(acc, String.to_atom(key), val) end)
  end
end
