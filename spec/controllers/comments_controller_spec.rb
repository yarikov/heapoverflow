require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let!(:question) { create(:question, user: user) }

  describe 'POST #create' do
    sign_in_user

    context 'with valid attributes' do
      it 'saves the new comment in the database' do
        expect do
          post :create,
               comment: attributes_for(:comment),
               question_id: question,
               user_id: @user,
               format: :js
        end.to change(question.comments, :count).by(1)
      end

      it 'creates new comment for user' do
        expect do
          post :create,
               comment: attributes_for(:comment),
               question_id: question,
               user_id: @user,
               format: :js
        end.to change(@user.comments, :count).by(1)
      end

      it 'render create template' do
        post :create,
             comment: attributes_for(:comment),
             question_id: question,
             user_id: @user,
             format: :js
        expect(response).to render_template :create
      end
    end

    context 'with invalid attributes' do
      it 'does not save the comment in the database' do
        expect do
          post :create,
               comment: attributes_for(:invalid_comment),
               question_id: question,
               user_id: user,
               format: :js
        end.to_not change(Comment, :count)
      end

      it 'render create template' do
        post :create,
             comment: attributes_for(:invalid_comment),
             question_id: question,
             user_id: user,
             format: :js
        expect(response).to render_template :create
      end
    end
  end
end
