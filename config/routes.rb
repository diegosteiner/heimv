# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, path: 'account', path_names: { sign_in: 'login', sign_out: 'logout' }
  resource :account, only: %i[edit update]

  scope '(:org)' do
    namespace :manage do
      root to: 'dashboard#index'
      get 'guide', to: 'pages#guide'
      get 'flow', to: 'pages#flow'
      resources :homes do
        scope module: :homes do
          resources :occupancies, except: %w[show], shallow: true
          resources :tarif_selectors, except: %w[show]
          resources :meter_reading_periods, only: %w[index]
          resources :tarifs do
            put '/', action: :update_many, on: :collection
            post :import, on: :collection
          end
        end
      end
      resource :organisation, only: %i[edit update show]
      resources :users, except: %i[show]
      resources :data_digests do
        get '/digest', on: :member, action: :digest, as: :digest
      end
      resources :invoices do
        resources :invoice_parts, except: %i[index show]
      end
      resources :payments, only: :index do
        match :new_import, via: %i[get post], on: :collection
        post :import, on: :collection
      end
      resources :bookings do
        get :import, on: :collection, to: 'bookings#new_import'
        post :import, on: :collection

        resources :invoices, shallow: true
        resources :payments, shallow: true
        resources :operator_responsibilities, except: %i[show], to: 'operator_responsibilities'
        resources :deadlines, shallow: true, only: %i[edit update]
        resources :notifications, shallow: true, only: %i[index show edit update]
        scope module: :bookings do
          resources :contracts
          resources :offers
          resources :tarifs
          resources :usages do
            collection do
              put '/', action: :update_many
            end
          end
        end
      end
      resources :tenants
      resources :operators, except: %i[show]
      resources :operator_responsibilities, except: %i[show]
      resources :booking_agents
      resources :booking_purposes, except: :show
      resources :rich_text_templates do
        post :create_missing, on: :collection
      end
    end

    scope module: :public do
      resource :organisation, only: :show
      get 'download/:slug', to: 'downloads#show', as: :download
      resources :agent_bookings, except: %i[destroy], as: :public_agent_bookings
      resources :bookings, only: %i[new create edit update], as: :public_bookings
      get 'b/:id(/edit)', to: 'bookings#edit'
      get 'changelog', to: 'pages#changelog'
      get 'privacy', to: 'pages#privacy'
      resources :homes, only: %i[show index] do
        resources :occupancies, only: %i[index show] do
          get :embed, on: :collection
          get :calendar, on: :collection
          get '@:date', on: :collection, as: :at, action: :at
        end
      end
      root to: 'pages#redirect'
    end
  end
end
