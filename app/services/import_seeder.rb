# frozen_string_literal: true

require 'faker'
require 'factory_bot_rails'

class ImportSeeder
  FILES = {
    demo: Rails.root.join('db/seeds/demo.json'),
    development: Rails.root.join('db/seeds/development.json')
  }.freeze

  def seed(set = Rails.env.to_sym)
    return unless FILES[set]

    truncate
    organisation = organisation(FILES[set])
    rich_text_templates(organisation)
    users(organisation)
    bookings(organisation.homes.first)
    reset_pk_sequence!
  end

  private

  def rich_text_templates(organisation)
    setup = OrganisationSetupService.new(organisation)
    setup.create_missing_rich_text_templates!
  end

  def organisation(file)
    import_data = JSON.parse(File.read(file))
    Import::Hash::OrganisationImporter.new.import(import_data).tap(&:save!)
  end

  def users(organisation, users: nil)
    users ||= [
      { email: 'admin@heimv.local', role: :admin, password: 'heimverwaltung' },
      { email: 'manager@heimv.local', role: :manager, password: 'heimverwaltung' }
    ]

    users.map { |user| User.create!(user.merge(organisation: organisation)) }
  end

  def bookings(home)
    FactoryBot.create_list(:booking, 3, home: home, initial_state: :open_request, notifications_enabled: true)
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
