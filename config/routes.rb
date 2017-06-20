# frozen_string_literal: true

Rails.application.routes.draw do
  resources :people
  get 'pages/home'
  get 'pages/about'

  root to: 'pages#home'
  devise_for :users
  resources :users
end
