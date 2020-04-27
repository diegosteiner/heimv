class DemoSeeder
  def seed
    ActiveRecord::Base.connection.truncate_tables(*ActiveRecord::Base.connection.tables)

    import_data = JSON.parse(File.read(Rails.root.join('db/seeds/development.json')))
    organisation = Import::OrganisationImporter.new(Organisation.new, replace: true).import(import_data)
    User.create!(role: :admin, password: 'heimverwaltung', email: 'admin@heimv.local', organisation: organisation)
  end
end
