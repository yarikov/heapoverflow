require 'sidekiq/web'

Rails.application.routes.draw do
  authenticate :user, -> (u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  use_doorkeeper

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

  resources :users, only: [:index, :show, :edit, :update] do
    resource :avatar, only: [:update, :destroy]
  end
  resources :tags,  only: [:index]

  resources :questions, concerns: [:commentable, :votable] do
    get 'tagged/:tag', action: :tagged, as: :tagged, on: :collection

    resources :answers, concerns: [:commentable, :votable], shallow: true do
      patch :best, on: :member
    end
    resource :subscription, only: [:create, :destroy]
  end

  namespace :api do
    namespace :v1 do
      resources :profiles, only: :index do
        get :me, on: :collection
      end
      resources :questions do
        resources :answers
      end
    end
  end
end
