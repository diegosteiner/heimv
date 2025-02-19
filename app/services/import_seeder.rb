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
    Rails.logger.info "Seeding #{set}"
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
    Rails.logger.info 'Adding rich text template'
    Dir.glob(File.expand_path('app/**/*.rb', Rails.root)).each do |model_file|
      require model_file
    end

    RichTextTemplateService.new(organisation).create_missing!
  end

  def organisation(file)
    import_data = JSON.parse(File.read(file))
    Rails.logger.info "Adding organisation #{import_data[:name]}"
    organisation = Import::Hash::OrganisationImporter.new.import(import_data)
    organisation.tap(&:save!)
  end

  def users(organisation, users: nil) # rubocop:disable Metrics/MethodLength
    onboarding = OnboardingService.new(organisation)
    users ||= [
      { email: 'admin@heimv.local', role: :admin, password: 'heimverwaltung' },
      { email: 'manager@heimv.local', role: :admin, password: 'heimverwaltung' },
      { email: 'reader@heimv.local', role: :readonly, password: 'heimverwaltung' }
    ]

    users.map do |user|
      Rails.logger.info "Adding user #{user[:email]} as #{user[:role]}"
      onboarding.add_or_invite_user!(**user)
    end
    User.find_by(email: 'admin@heimv.local').update(role_admin: true)
  end

  def bookings(home)
    Rails.logger.info "Adding bookings for #{home.name}"
    FactoryBot.create_list(:booking, 3, home:, organisation: home.organisation,
                                        initial_state: :open_request, notifications_enabled: true)
  end

  def truncate
    Rails.logger.info 'Trucating all tables'
    tables = ActiveRecord::Base.connection.tables - %w[schema_migrations ar_internal_metadata]
    ActiveRecord::Base.connection.truncate_tables(*tables)
  end

  def reset_pk_sequence!
    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end
end
