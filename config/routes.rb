# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :users
    resource :import, only: %i[new create show]
  end

  namespace :manage do
    get '/', to: 'dashboard#index', as: :manage_dashboard
    resources :homes do
      scope module: :homes do
        resources :tarif_selectors, except: %w[show]
        resources :meter_reading_periods, only: %w[index]
        resources :tarifs do
          collection do
            put '/', action: :update_many
          end
        end
      end
    end
    resource :organisation, only: %i[edit update show]
    resources :data_digests do
      get '/period', on: :member, action: :period, as: :period
    end
    resources :invoices do
      resources :invoice_parts, except: %i[index show]
    end
    resources :payments, only: :index do
      match :new_import, via: %i[get post], on: :collection
      post :import, on: :collection
    end
    resources :bookings do
      resources :invoices, shallow: true
      resources :payments, shallow: true
      resources :messages, shallow: true, only: %i[index show edit update]
      scope module: :bookings do
        resources :contracts
        resources :tarifs
        resources :usages do
          collection do
            put '/', action: :update_many
          end
        end
      end
    end
    resources :tenants
    resources :booking_agents
    resources :markdown_templates do
      post :create_missing, on: :collection
    end
  end

  root to: 'pages#home'
  devise_for :users, path: 'account', path_names: { sign_in: 'login', sign_out: 'logout' }

  scope module: :public do
    get 'pages/home'
    get 'pages/about'
    get 'download/:slug', to: 'downloads#show', as: :download
    # get 'at/:t', to: 'pages/home', as: :occupancy_at
    resources :agent_bookings, except: %i[destroy], as: :public_agent_bookings
    resources :bookings, only: %i[new create edit update], path: 'b', as: :public_bookings
    resources :homes, only: [] do
      resources :occupancies, only: %i[index show] do
        get :embed, on: :collection
        get :calendar, on: :collection
        get :at, on: :collection
      end
    end
  end
end
