require 'rails_helper'

describe 'Questions API' do
  describe 'GET /index' do
    it_behaves_like 'API Authenticable'

    context 'authorized' do
      let(:user)         { create(:user) }
      let(:access_token) { create(:access_token) }
      let!(:questions)   { create_list(:question, 2, user: user) }

      before do
        get '/api/v1/questions', params: {
          access_token: access_token.token,
          format: :json
        }
      end

      it 'returns 200 status code' do
        expect(response).to be_successful
      end

      it 'returns list of questions' do
        expect(response.body).to have_json_size(2).at_path('questions')
      end

      %w(id title body created_at updated_at).each do |attr|
        it "question object contains #{attr}" do
          expect(response.body)
            .to be_json_eql(questions[0].send(attr.to_sym).to_json)
            .at_path("questions/1/#{attr}")
        end
      end
    end

    def do_request(options = {})
      get '/api/v1/questions', params: { format: :json }.merge(options)
    end
  end

  describe 'GET /show' do
    let(:user)             { create(:user) }
    let!(:question)        { create(:question) }

    let!(:old_answer)      { create(:old_answer, question: question) }
    let!(:qst_old_comment) { create(:old_comment, commentable: question) }
    let!(:ans_old_comment) { create(:old_comment, commentable: answer) }

    let!(:answer)          { create(:answer, question: question) }
    let!(:qst_comment)     { create(:comment, commentable: question) }
    let!(:ans_comment)     { create(:comment, commentable: answer) }

    it_behaves_like 'API Authenticable'

    context 'authorized' do
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }

      before do
        get "/api/v1/questions/#{question.id}", params: {
          access_token: access_token.token,
          format: :json
        }
      end

      it 'returns 200 status code' do
        expect(response).to be_successful
      end

      it 'returns question attributes' do
        expect(response.body).to have_json_size(8).at_path('question')
      end

      %w(id title body user_id created_at updated_at).each do |attr|
        it "question object contains #{attr}" do
          expect(response.body)
            .to be_json_eql(question.send(attr.to_sym).to_json)
            .at_path("question/#{attr}")
        end
      end

      context 'comments' do
        it 'included in question object' do
          expect(response.body)
            .to have_json_size(2).at_path('question/comments')
        end

        %w(id body user_id created_at updated_at).each do |attr|
          it "contains #{attr}" do
            expect(response.body)
              .to be_json_eql(qst_comment.send(attr.to_sym).to_json)
              .at_path("question/comments/1/#{attr}")
          end
        end
      end

      context 'answers' do
        it 'included in question object' do
          expect(response.body)
            .to have_json_size(2).at_path('question/answers')
        end

        %w(id body user_id created_at updated_at).each do |attr|
          it "contains #{attr}" do
            expect(response.body)
              .to be_json_eql(answer.send(attr.to_sym).to_json)
              .at_path("question/answers/1/#{attr}")
          end
        end

        context 'comments' do
          it 'included in answer object' do
            expect(response.body)
              .to have_json_size(2).at_path('question/answers/1/comments')
          end

          %w(id body user_id created_at updated_at).each do |attr|
            it "contains #{attr}" do
              expect(response.body)
                .to be_json_eql(ans_comment.send(attr.to_sym).to_json)
                .at_path("question/answers/1/comments/1/#{attr}")
            end
          end
        end
      end
    end

    def do_request(options = {})
      get "/api/v1/questions/#{question.id}",
          params: { format: :json }.merge(options)
    end
  end

  describe 'POST /create' do
    it_behaves_like 'API Authenticable'

    context 'authorized' do
      let(:user)         { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }

      context 'with valid attributes' do
        let(:request) do
          post '/api/v1/questions', params: {
            question: attributes_for(:question),
            access_token: access_token.token,
            format: :json
          }
        end

        it 'returns 201 status code' do
          request
          expect(response).to be_successful
        end

        it 'saves the new question in the database' do
          expect { request }.to change(user.questions, :count).by(1)
        end
      end

      context 'with invalid attributes' do
        let(:request) do
          post '/api/v1/questions', params: {
            question: attributes_for(:invalid_question),
            access_token: access_token.token,
            format: :json
          }
        end

        it 'returns 422 status code' do
          request
          expect(response.status).to eq 422
        end

        it 'does not save the question in the database' do
          expect { request }.to_not change(Question, :count)
        end
      end
    end

    def do_request(options = {})
      post '/api/v1/questions', params: { format: :json }.merge(options)
    end
  end
end
