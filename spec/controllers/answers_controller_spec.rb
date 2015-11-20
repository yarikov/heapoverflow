require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:answer) { create(:answer, question: question, user: user) }

  describe 'POST #create' do
    sign_in_user
    context 'with valid attributes' do
      it 'saves the new answer in the database' do
        expect do
          post :create,
               answer: attributes_for(:answer), question_id: question, user_id: user
        end.to change(question.answers, :count).by(1)
      end

      it 'creates new answer for user' do
        expect do
          post :create,
               answer: attributes_for(:answer), question_id: question, user_id: user
        end.to change(@user.answers, :count).by(1)
      end

      it 'redirects to question show view' do
        post :create, answer: attributes_for(:answer), question_id: question, user_id: user
        expect(response).to redirect_to question
      end
    end

    context 'with invalid attributes' do
      it 'does not save the answer in the database' do
        expect do
          post :create,
               answer: attributes_for(:invalid_answer), question_id: question, user_id: user
        end.to_not change(Answer, :count)
      end

      it 'redirects to question show view' do
        post :create, answer: attributes_for(:invalid_answer), question_id: question, user_id: user
        expect(response).to redirect_to question
      end
    end
  end

  describe 'DELETE #destroy' do
    sign_in_user

    context 'User delete own answer' do
      let(:answer) { create(:answer, question: question, user: @user) }

      it 'delete the answer' do
        answer
        expect { delete :destroy, id: answer }.to change(@user.answers, :count).by(-1)
      end
    end

    context "User delete someone else's answer" do
      let(:answer) { create(:answer, question: question, user: user) }

      it 'does not delete the answer' do
        answer
        expect { delete :destroy, id: answer }.to_not change(Answer, :count)
      end
    end
  end
end
