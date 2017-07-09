# frozen_string_literal: true

Rails.application.routes.draw do
  resources :homes
  resources :contracts
  resources :bookings
  resources :people
  get 'pages/home'
  get 'pages/about'

  root to: 'pages#home'
  devise_for :users
  resources :users
end
