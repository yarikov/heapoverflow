require 'rails_helper'

describe 'Profile API' do
  describe 'GET /me' do
    it_behaves_like 'API Authenticable'

    context 'authorized' do
      let(:me)           { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }

      before do
        get '/api/v1/profiles/me', params: {
          access_token: access_token.token,
          format: :json
        }
      end

      it 'returns 200 status' do
        expect(response).to be_success
      end

      %w(id full_name created_at updated_at admin).each do |attr|
        it "contains #{attr}" do
          expect(response.body)
            .to be_json_eql(me.send(attr.to_sym).to_json)
            .at_path("user/#{attr}")
        end
      end

      %w(password encrypted_password).each do |attr|
        it "does not contain #{attr}" do
          expect(response.body).to_not have_json_path("user/#{attr}")
        end
      end
    end

    def do_request(options = {})
      get '/api/v1/profiles/me', params: { format: :json }.merge(options)
    end
  end

  describe 'GET /index' do
    it_behaves_like 'API Authenticable'

    context 'authorized' do
      let!(:users) { create_list(:user, 2) }
      let(:access_token) do
        create(:access_token, resource_owner_id: users[0].id)
      end

      before do
        get '/api/v1/profiles', params: {
          access_token: access_token.token,
          format: :json
        }
      end

      it 'returns 200 status' do
        expect(response).to be_success
      end

      it 'does not contain current_resource_owner' do
        expect(response.body).to_not include_json(users[0].to_json)
      end

      %w(id full_name created_at updated_at admin).each do |attr|
        it "contains #{attr}" do
          expect(response.body)
            .to be_json_eql(users[1].send(attr.to_sym).to_json)
            .at_path("users/0/#{attr}")
        end
      end

      %w(password encrypted_password).each do |attr|
        it "does not contain #{attr}" do
          expect(response.body).to_not have_json_path("users/0/#{attr}")
        end
      end
    end

    def do_request(options = {})
      get '/api/v1/profiles', params: { format: :json }.merge(options)
    end
  end
end
