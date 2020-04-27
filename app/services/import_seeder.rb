class ImportSeeder
  FILES = {
    demo: Rails.root.join('db/seeds/demo.json'),
    development: Rails.root.join('db/seeds/development.json')
  }.freeze

  def seed(set = Rails.env.to_sym)
    return unless FILES[set]

    import_data = JSON.parse(File.read(FILES[set]))
    truncate
    organisation = Import::OrganisationImporter.new(Organisation.new, replace: true).import(import_data)
    User.create!(role: :admin, password: 'heimverwaltung', email: 'admin@heimv.local', organisation: organisation)
  end

  def truncate
    tables = ActiveRecord::Base.connection.tables - %w[schema_migrations ar_internal_metadata]
    ActiveRecord::Base.connection.truncate_tables(*tables)
  end
end
