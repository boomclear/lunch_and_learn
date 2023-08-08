class FavoritesSerializer
include JSONAPI::Serializer
  attributes :recipe_title, :recipe_link, :country, :created_at

  set_type :favorite
end