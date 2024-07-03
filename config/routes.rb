Rails.application.routes.draw do
  authenticate :user, ->(u) { u.admin? } do
    mount MissionControl::Jobs::Engine, at: 'mission_control/jobs'
  end

  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }
  devise_scope(:user) { post :twitter, to: 'omniauth_callbacks#twitter' }

  root 'questions#index'
  get 'search', to: 'search#search'

  concern :commentable do
    resources :comments
  end

  concern :votable do
    resource :vote, only: :destroy do
      patch :up
      patch :down
    end
  end

  resources :users, only: %i[index show edit update] do
    resource :avatar, only: %i[update destroy]
  end
  resources :tags, only: [:index]

  resources :questions, concerns: %i[commentable votable] do
    get 'tagged/:tag', action: :tagged, as: :tagged, on: :collection

    resources :answers, concerns: %i[commentable votable], shallow: true do
      patch :best, on: :member
    end
    resource :subscription, only: %i[create destroy]
  end
end
