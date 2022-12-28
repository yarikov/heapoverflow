# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'User deletes an avatar', type: :system do
  let_it_be(:user) { create(:user_with_profile) }

  it 'works' do
    login_as(user)
    visit edit_user_path(user)

    expect(user.avatar).to be_attached
    click_on(class: 'avatar-uploader__remove-btn')

    expect(user.reload.avatar).to_not be_attached
  end
end
