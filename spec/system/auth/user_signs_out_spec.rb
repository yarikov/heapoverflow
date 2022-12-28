# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Sign out', type: :system do
  let(:user) { create(:user) }

  context 'when the authenticated user' do
    it 'works' do
      login_as(user)
      visit root_path

      find('.dropdown__avatar').click
      click_on 'Sign out', match: :first

      expect(page).to have_content 'Sign in'
    end
  end
end
