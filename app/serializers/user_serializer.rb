class UserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :avatar_path, :created_at, :updated_at, :admin

  def avatar_path
    view_context.avatar_path(object, :medium)
  end
end
