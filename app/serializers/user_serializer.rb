class UserSerializer
  include JSONAPI::Serializer
  attributes :name, :email

  attribute :api_key do |object|
    object.api_keys.first.token
  end
end
