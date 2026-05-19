# frozen_string_literal: true

module Oauth
  class FindOrCreateUser < ApplicationService
    def initialize(auth)
      @auth = auth
    end

    def call
      authorization = Authorization.find_by(provider: auth.provider, uid: auth.uid.to_s)
      return authorization.user if authorization
      return User.new unless auth.info&.email

      user = User.find_or_create_by!(email: auth.info.email) do |u|
        u.full_name = auth.info.name
        u.password = Devise.friendly_token[0, 20]
        u.skip_confirmation! if auth.credentials
      end
      user.authorizations.create(provider: auth.provider, uid: auth.uid)
      user
    end

    private

    attr_reader :auth
  end
end
