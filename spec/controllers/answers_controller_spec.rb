require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:answer) { create(:answer, question: question, user: user) }

  let(:own_votable) { create(:answer, question: question, user: @user) }
  let(:votable) { create(:answer, question: question, user: user) }

  it_behaves_like 'Votable'

  describe 'POST #create' do
    sign_in_user
    context 'with valid attributes' do
      let(:channel) { "/questions/#{question.id}/answers" }
      let(:request) do
        post :create, question_id: question, answer: attributes_for(:answer), format: :js
      end

      it 'saves the new answer in the database' do
        expect { request }.to change(question.answers, :count).by(1)
      end

      it 'creates new answer for user' do
        expect { request }.to change(@user.answers, :count).by(1)
      end

      it 'render create template' do
        request
        expect(response).to render_template :create
      end

      it_behaves_like 'Publishable'
    end

    context 'with invalid attributes' do
      let(:request) do
        post :create, question_id: question, answer: attributes_for(:invalid_answer), format: :js
      end

      it 'does not save the answer in the database' do
        expect { request }.to_not change(Answer, :count)
      end

      it 'render create template' do
        request
        expect(response).to render_template :create
      end
    end
  end

  describe 'PATCH #update' do
    sign_in_user
    let(:answer) { create(:answer, question: question, user: @user) }

    it 'assings the requested answer to @answer' do
      patch :update, id: answer, answer: attributes_for(:answer), format: :js
      expect(assigns(:answer)).to eq answer
    end

    it 'changes answer attributes' do
      patch :update, id: answer, answer: { body: 'new answer body' }, format: :js
      answer.reload
      expect(answer.body).to eq 'new answer body'
    end

    it 'render update template' do
      patch :update, id: answer, answer: attributes_for(:answer), format: :js
      expect(response).to render_template :update
    end
  end

  describe 'DELETE #destroy' do
    sign_in_user

    context 'User delete own answer' do
      let!(:answer) { create(:answer, question: question, user: @user) }

      it 'delete the answer' do
        expect { delete :destroy, id: answer, format: :js }.to change(@user.answers, :count).by(-1)
      end
    end

    context "User delete someone else's answer" do
      let!(:answer) { create(:answer, question: question, user: user) }

      it 'does not delete the answer' do
        expect { delete :destroy, id: answer, format: :js }.to_not change(Answer, :count)
      end
    end
  end

  describe 'PATCH #best' do
    sign_in_user

    let(:question) { create(:question, user: @user) }
    let(:answer) { create(:answer, question: question, user: user) }

    before { patch :best, id: answer, format: :js }

    it 'assings the requested answer to @answer' do
      expect(assigns(:answer)).to eq answer
    end

    it 'render best template' do
      expect(response).to render_template :best
    end
  end
end
