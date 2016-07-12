shared_examples_for 'Votable' do
  describe 'PATCH #vote_up' do
    sign_in_user

    context 'when author' do
      it 'render json' do
        patch :vote_up, params: { id: own_votable, format: :json }
        json = JSON.parse(response.body)

        expect(json['error'])
          .to eql "The author of the #{own_votable.class.to_s.underscore} cannot vote up"
      end
    end

    context 'when authenticated user' do
      render_views

      it 'render json' do
        patch :vote_up, params: { id: votable, format: :json }
        json = JSON.parse(response.body)

        expect(json['id']).to eql(votable.id)
        expect(json['vote_count']).to eql(votable.vote_count)
        expect(json['vote_up']).to eql true
        expect(json['vote_down']).to eql false
      end
    end
  end

  describe 'PATCH #vote_down' do
    sign_in_user

    context 'when author' do
      it 'render json' do
        patch :vote_down, params: { id: own_votable, format: :json }
        json = JSON.parse(response.body)

        expect(json['error'])
          .to eql "The author of the #{own_votable.class.to_s.underscore} cannot vote down"
      end
    end

    context 'when authenticated user' do
      render_views

      it 'render json' do
        patch :vote_down, params: { id: votable, format: :json }
        json = JSON.parse(response.body)

        expect(json['id']).to eql(votable.id)
        expect(json['vote_count']).to eql(votable.vote_count)
        expect(json['vote_up']).to eql false
        expect(json['vote_down']).to eql true
      end
    end
  end
end
