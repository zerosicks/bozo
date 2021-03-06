Rails.application.routes.draw do
  resources :maps do
    resources :connections
    get "track", on: :member
  end
  devise_for :users, :controllers => { omniauth_callbacks: "users/omniauth_callbacks", registrations: "users/registrations", sessions: "users/sessions" }
  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new', as: :new_user_session
    match 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session, via: [:get, :delete]
  end

  root to: "maps#index"
end
