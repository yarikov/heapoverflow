class UserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :avatar, :created_at, :updated_at, :admin
end
