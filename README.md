# Heimverwaltung

## Setup with Docker

```sh
git clone git@github.com:diegosteiner/heimv.git
cd heimv
docker-compose up app
```

or with VS Code

- Start in Container with Remote Containers Extension

### Development Servers

Then inside the container run:

- `bin/rails s -b 0.0.0.0` to start rails server
- `bin/webpack-dev-server` to start webpack dev server

To visit the automatically created default organization, visit http://localhost:3000/.

### Commands

- Setup DB: `bin/rails db:prepare`
- Run migrations: `bin/rails db:migrate`
- Run checks: `bin/check`
- Run e2e Tests: `bin/e2e`

### Configuration

Copy env.example to .env and change configuration there

## Embed

```
<iframe
  sandbox="allow-same-origin allow-scripts allow-top-navigation-by-user-activation allow-top-navigation"
  src="https://app.heimv.ch/{{organisation.slug}}/homes/{{home.id}}/occupancies/embed?display_months=9"
  border="0"
  style="width: 100%; overflow-x: hidden; overflow-y: scroll; height: 960px; border: none;">
</iframe>
```

## Add Organisation

Create a organisation with markdown templates and a user:

```
setup = OrganisationSetupService.create(name: <name>, email: <email>, slug: <slug>)
setup.create_missing_rich_text_templates!(include_optional: true)
setup.create_user!
```

## Cronjobs

Automatically change after some time has passed:

```
bin/rails r TransitionBookingStatesJob.perform_now
```

Resend failed Notification attemps:

```
bin/rails r RetryFailedNotificationsJob.perform_now
```

## Import data

### Bookings

Prepare a csv with these columns, including a header, as utf-8:

- begins_at (as ISO8601)
- ends_at (as ISO8601)
- email (optional)
- ref (which will set the reference, optional)
- remarks (optional)
- organisation (which refers to the tenants organisation, optional)
- purpose (which corresponds to the purpose keys set for the organisation, optional)
- phone

Options:

- initial_state: State to which the booking shall be transitioned
- default_purpose: 

Then import data with:

```
cat data.csv | bin/rails r "Import::Csv::OccupancyImporter.new(home).read(ARGF, **options)"
```

or with heroku:

```
cat data.csv | heroku run --no-tty -- 'bin/rails r "Import::Csv::OccupancyImporter.new(home).read"'
```

### Tenants

Prepare a csv with these columns, including a header, as utf-8:

- first_name
- last_name
- street_address
- zipcode
- city
- phone
- email

Then import data with:

```
cat data.csv | bin/rails r Import::Csv::TenantImporter.new(organisation).read
```

## Copyright & License

🎂 1000th commit 🎂

Coypright 2017 Diego P. Steiner & contributors

If you want to use HeimV in a commercial setting, a commercial licence
is required. For a commercial licence please get in touch: license@heimv.ch.
Other than that, the project is licensed under the AGPLv3 License.
See LICENCE for details.
