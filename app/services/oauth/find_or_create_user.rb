# frozen_string_literal: true

module Oauth
  class FindOrCreateUser < ApplicationService
    def initialize(auth)
      @auth = auth
    end

    def call
      find_user_by_authorization ||
        build_guest_user ||
        find_or_create_authenticated_user.tap { |user| create_authorization!(user) }
    end

    private

    attr_reader :auth

    def find_user_by_authorization
      Authorization.find_by(provider: auth.provider, uid: auth.uid.to_s)&.user
    end

    def build_guest_user
      User.new unless auth.info&.email
    end

    def find_or_create_authenticated_user
      User.find_or_create_by!(email: auth.info.email) do |user|
        user.full_name = auth.info.name
        user.password = Devise.friendly_token[0, 20]
        user.skip_confirmation! if auth.credentials
      end
    end

    def create_authorization!(user)
      user.authorizations.create!(provider: auth.provider, uid: auth.uid)
    end
  end
end
