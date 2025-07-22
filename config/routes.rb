# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, path: 'account', controllers: {
    sessions: 'accounts/sessions', passwords: 'accounts/passwords'
  }, path_names: { sign_in: 'login', sign_out: 'logout' }
  resource :account, only: %i[edit update destroy]

  get 'health', to: 'public/pages#health'
  get 'changelog', to: 'public/pages#changelog'

  scope '(:org)' do
    namespace :manage do
      root to: 'bookings#calendar'
      get 'dashboard', to: 'dashboard#index'
      get 'flow', to: 'pages#flow'
      resources :occupiables do
        get 'calendar', on: :member
        resources :occupancies, only: %i[index new create]
      end
      resources :occupancies, only: %w[new create edit update destroy]
      resource :organisation, only: %i[edit update show]
      resources :organisation_users, except: %i[show]
      resources :booking_questions
      resources :booking_validations
      resources :data_digests, except: %i[update edit]
      resources :data_digest_templates
      resources :plan_b_backups, only: %i[index]
      resources :invoices do
        resources :invoice_parts, except: %i[index show]
      end
      resources :payments, only: :index do
        match :new_import, via: %i[get post], on: :collection
        post :import, on: :collection
      end
      resources :tarifs do
        put '/', action: :update_many, on: :collection
        post :import, on: :collection
      end
      resources :bookings do
        get :import, on: :collection, to: 'bookings#new_import'
        get :calendar, on: :collection
        post :import, on: :collection

        resources :invoices, shallow: true
        resources :payments, shallow: true
        resources :operator_responsibilities, except: %i[show] do
          post :assign, on: :collection
        end
        resource :deadline, shallow: true, only: %i[edit update]
        resources :notifications, shallow: true
        scope module: :bookings do
          post 'actions(/:id)', to: 'booking_actions#invoke', as: :invoke_action
          get 'actions(/:id)', to: 'booking_actions#prepare', as: :prepare_action
          resources :contracts
          resources :usages, only: %w[index edit update destroy] do
            put :/, action: :update_many, on: :collection
          end
        end
      end
      resources :tenants
      resources :operators
      resources :operator_responsibilities, except: %i[show]
      resources :designated_documents
      resources :booking_agents
      resources :booking_categories, except: :show
      resources :vat_categories, except: :show
      resources :journal_entry_batches, only: %i[index update destroy] do
        post :process_all, on: :collection
      end
      resources :notifications, only: %i[index]
      resources :rich_text_templates do
        post :create_missing, on: :collection
      end
    end

    scope module: :public do
      resource :organisation, only: :show
      get 'designated_documents/:designation', to: 'designated_documents#show', as: :public_designated_document
      resources :agent_bookings, except: %i[destroy], as: :public_agent_bookings
      resources :bookings, except: :destroy, as: :public_bookings do
        scope module: :bookings do
          post 'actions(/:id)', to: 'booking_actions#invoke', as: :invoke_action
          get 'actions(/:id)', to: 'booking_actions#prepare', as: :prepare_action
        end
      end
      get 'privacy', to: 'pages#privacy'
      resources :homes, only: %i[show index] do
        resources :occupancies, only: %i[index show] do
          collection do
            get :embed
            get :calendar
            get :at
            get '@:date', action: :at
          end
        end
      end
      resources :occupiables, only: [] do
        resource :calendar, only: [] do
          get :embed
          get :index
          get :at
          get :private_ical_feed
          get '@:date', action: :at
        end
      end
      root to: 'pages#home'
    end
  end
end
