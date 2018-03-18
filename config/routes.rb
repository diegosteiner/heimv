# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :users
  end

  namespace :manage do
    get 'dashboard', to: 'dashboard#index'
    resources :homes
    resources :bookings do
      resources :contracts, shallow: true
    end
    resources :customers
    resources :booking_agents
  end

  get 'pages/home'
  get 'pages/about'
  root to: 'pages#home'
  devise_for :users, path: 'account', path_names: { sign_in: 'login', sign_out: 'logout' }

  scope module: :public do
    resources :bookings, only: %i[new create edit update], path: 'b', as: :public_bookings
  end
end
