# frozen_string_literal: true

require 'rails_helper'

RSpec.xdescribe CommentsController, type: :controller do
  let(:user)     { create(:user) }
  let(:question) { create(:question, user: user) }

  describe 'POST #create' do
    sign_in_user

    context 'with valid attributes' do
      let(:channel) { "/questions/#{question.id}/comments" }
      let(:request) do
        post :create, params: {
          question_id: question,
          comment: attributes_for(:comment),
          format: :js
        }
      end

      it 'saves the new comment in the database' do
        expect { request }.to change(question.comments, :count).by(1)
      end

      it 'creates new comment for user' do
        expect { request }.to change(@user.comments, :count).by(1)
      end

      it 'render create template' do
        request
        expect(response).to render_template :create
      end
    end

    context 'with invalid attributes' do
      let(:request) do
        post :create, params: {
          question_id: question,
          comment: attributes_for(:invalid_comment),
          format: :js
        }
      end

      it 'does not save the comment in the database' do
        expect { request }.to_not change(Comment, :count)
      end

      it 'render create template' do
        request
        expect(response).to render_template :create
      end
    end
  end
end
