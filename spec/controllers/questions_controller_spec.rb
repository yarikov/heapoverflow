require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }

  let(:own_votable) { create(:question, user: @user) }
  let(:votable) { create(:question, user: user) }

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
    before { get :show, id: question }

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
      let(:request) { post :create, question: attributes_for(:question) }

      it 'saves the new question in the database' do
        expect { request }.to change(@user.questions, :count).by(1)
      end

      it 'redirects to show view' do
        request
        expect(response).to redirect_to question_path(assigns(:question))
      end

      it_behaves_like 'Publishable'
    end

    context 'with invalid attributes' do
      let(:request) { post :create, question: attributes_for(:invalid_question) }

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

    let(:question) { create(:question, user: @user) }

    it 'assings the requested question to @question' do
      patch :update, id: question, question: attributes_for(:question), format: :js
      expect(assigns(:question)).to eq question
    end

    it 'changes question attributes' do
      patch :update, id: question, question: { title: 'new question title', body: 'new question body' }, format: :js
      question.reload
      expect(question.title).to eq 'new question title'
      expect(question.body).to eq 'new question body'
    end

    it 'render update template' do
      patch :update, id: question, question: attributes_for(:question), format: :js
      expect(response).to render_template :update
    end
  end

  describe 'DELETE #destroy' do
    sign_in_user

    context 'User delete own question' do
      let(:question) { create(:question, user: @user) }

      it 'delete the question' do
        question
        expect { delete :destroy, id: question }.to change(@user.questions, :count).by(-1)
      end

      it 'redirects to index' do
        delete :destroy, id: question
        expect(response).to redirect_to questions_path
      end
    end

    context "User delete someone else's question" do
      let!(:question) { create(:question, user: user) }

      it 'does not delete the question' do
        expect { delete :destroy, id: question }.to_not change(Question, :count)
      end
    end
  end
end
