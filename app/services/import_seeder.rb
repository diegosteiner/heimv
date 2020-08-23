# frozen_string_literal: true

require 'faker'
require 'factory_bot_rails'

class ImportSeeder
  FILES = {
    demo: Rails.root.join('db/seeds/demo.json'),
    development: Rails.root.join('db/seeds/development.json')
  }.freeze

  def seed(set = Rails.env.to_sym, password: 'heimverwaltung', email: 'admin@heimv.local')
    return unless FILES[set]

    role = set == :development ? :admin : :manager
    import_data = JSON.parse(File.read(FILES[set]))
    truncate
    organisation = Import::OrganisationImporter.new(Organisation.new, replace: true).import(import_data)
    User.create!(role: role, password: password, email: email, organisation: organisation)
    reset_pk_sequence!
    bookings(organisation.homes.first)
  end

  private

  def bookings(home)
    FactoryBot.create_list(:booking, 3, home: home, initial_state: :open_request)
    # FactoryBot.create_list(:booking, 1, home: home, initial_state: :provisional_request)
    # FactoryBot.create_list(:booking, 2, home: home, initial_state: :defintive_request)
    # FactoryBot.create_list(:booking, 1, home: home, initial_state: :awaiting_contract).each do |booking|
    #   booking.contracts.create
    # end
  end

  def truncate
    tables = ActiveRecord::Base.connection.tables - %w[schema_migrations ar_internal_metadata]
    ActiveRecord::Base.connection.truncate_tables(*tables)
  end

  def reset_pk_sequence!
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end
end
