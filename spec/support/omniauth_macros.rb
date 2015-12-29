module OmniauthMacros
  def mock_auth_hash
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(
      provider: 'facebook',
      uid: '12345',
      info: {
        email: 'test@email.com'
      }
    )
    OmniAuth.config.add_mock(:twitter, uid: '12345')
  end
end
