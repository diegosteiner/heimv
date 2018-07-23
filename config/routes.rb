# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :users
  end

  namespace :manage do
    get '/', to: 'dashboard#index', as: :manage_dashboard
    resources :homes do
      resources :tarifs, controller: 'home_tarifs' do
        collection do
          put '/', action: :update_all
        end
      end
    end
    resources :bookings do
      scope module: :bookings do
        resources :contracts
        resources :tarifs
        resources :usages
        resources :invoices do
          resources :invoice_parts, except: %i[index show]
        end
      end
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
    resources :homes, only: [] do
      resources :occupancies, only: %i[index show]
    end
  end
end
