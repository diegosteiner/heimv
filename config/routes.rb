# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :users
  end

  namespace :manage do
    resources :homes
    resources :bookings do
      resources :contracts, shallow: true
    end
    resources :customers
  end

  get 'pages/home'
  get 'pages/about'
  root to: 'pages#home'
  devise_for :users

  scope module: :public do
    resources :bookings, only: %i[new create edit update], path: 'b', as: :public_bookings
  end
end
