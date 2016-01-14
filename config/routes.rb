Rails.application.routes.draw do
  use_doorkeeper

  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }
  devise_scope(:user) { post :twitter, to: 'omniauth_callbacks#twitter' }

  root 'questions#index'

  concern :voted do
    member do
      patch :vote_up
      patch :vote_down
    end
  end

  resources :questions, concerns: :voted do
    resources :comments
    resources :answers, concerns: :voted, shallow: true do
      resources :comments
      patch :best, on: :member
    end
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
