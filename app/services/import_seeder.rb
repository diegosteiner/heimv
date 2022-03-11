# frozen_string_literal: true

require 'faker'
require 'factory_bot_rails'

class ImportSeeder
  FILES = {
    demo: Rails.root.join('db/seeds/demo.json'),
    development: Rails.root.join('db/seeds/development.json'),
    test: Rails.root.join('db/seeds/development.json')
  }.freeze

  def seed(set = Rails.env.to_sym)
    return unless FILES[set]

    truncate
    organisation = organisation(FILES[set])
    rich_text_templates(organisation)
    users(organisation)
    bookings(organisation.homes.first)
    reset_pk_sequence!
    true
  end

  private

  def rich_text_templates(organisation)
    setup = OnboardingService.new(organisation)
    setup.create_missing_rich_text_templates!
  end

  def organisation(file)
    import_data = JSON.parse(File.read(file))
    Import::Hash::OrganisationImporter.new.import(import_data).tap(&:save!)
  end

  def users(organisation, users: nil)
    onboarding = OnboardingService.new(organisation)
    users ||= [
      { email: 'manager@heimv.local', role: :manager, password: 'heimverwaltung' },
      { email: 'reader@heimv.local', role: :readonly, password: 'heimverwaltung' }
    ]

    users.map do |user|
      onboarding.add_or_invite_user!(role: user[:role], email: user[:email], password: user[:password])
    end
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
