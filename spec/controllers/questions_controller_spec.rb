require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  let(:user)        { create(:user) }
  let(:question)    { create(:question, user: user) }

  let(:own_votable) { create(:question, user: @user) }
  let(:votable)     { create(:question, user: user) }

  it_behaves_like 'Votable'

  describe 'GET #index' do
    let(:questions) { create_list(:question, 2, user: user) }

    before { get :index }

    it 'populates an array of all questions' do
      expect(assigns(:questions)).to match_array(questions)
    end

    it 'renders index view' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: question } }

    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'assigns new answer for question' do
      expect(assigns(:answer)).to be_a_new(Answer)
    end

    it 'renders show view' do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    sign_in_user

    before { get :new }

    it 'assigns a new Question to @question' do
      expect(assigns(:question)).to be_a_new(Question)
    end

    it 'renders new view' do
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    sign_in_user

    context 'with valid attributes' do
      let(:channel) { '/questions' }
      let(:request) do
        post :create, params: { question: attributes_for(:question) }
      end

      it 'saves the new question in the database' do
        expect { request }.to change(@user.questions, :count).by(1)
      end

      it 'redirects to show view' do
        request
        expect(response).to redirect_to question_path(assigns(:question))
      end

      it_behaves_like 'Broadcastable'
    end

    context 'with invalid attributes' do
      let(:request) do
        post :create, params: { question: attributes_for(:invalid_question) }
      end

      it 'does not save the question in the database' do
        expect { request }.to_not change(Question, :count)
      end

      it 're-renders new view' do
        request
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    sign_in_user

    let(:question)       { create(:question, user: @user) }
    let(:qst_attributes) { attributes_for(:question) }

    before do
      patch :update, params: {
        id: question,
        question: qst_attributes,
        format: :js
      }
    end

    it 'assings the requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'changes question attributes' do
      question.reload
      expect(question.title).to eq qst_attributes[:title]
      expect(question.body).to eq qst_attributes[:body]
    end

    it 'render update template' do
      expect(response).to render_template :update
    end
  end

  describe 'DELETE #destroy' do
    sign_in_user

    context 'User delete own question' do
      let(:question) { create(:question, user: @user) }
      let(:request)  { delete :destroy, params: { id: question } }

      it 'delete the question' do
        question
        expect { request }.to change(@user.questions, :count).by(-1)
      end

      it 'redirects to index' do
        request
        expect(response).to redirect_to questions_path
      end
    end

    context "User delete someone else's question" do
      let!(:question) { create(:question, user: user) }

      it 'does not delete the question' do
        expect { request }.to_not change(Question, :count)
      end
    end
  end
end
