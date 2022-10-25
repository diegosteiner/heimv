![HeimV Logo](app/javascript/images/logo.png)

# HeimV Heimverwaltung

## Development

```sh
git clone git@github.com:diegosteiner/heimv.git
cd heimv
docker-compose up app
```

or with VS Code

- Start in Container with Remote Containers Extension

### Development Servers

Then inside the container you may run:

- `bin/rails-dev-server` to start rails server
- `bin/webpacker-dev-server` to start webpack dev server
- `bin/queue` to start the sidekiq worker process

To visit the automatically created default organization, visit http://localhost:3000/.

### Commands

- Setup DB: `bin/rails db:prepare`
- Run migrations: `bin/rails db:migrate`
- Run checks: `bin/check`
- Run e2e Tests: `bin/e2e`

### Configuration

Copy env.example to .env and change configuration there

## Embed Calendar for a Home

```
<iframe
  sandbox="allow-same-origin allow-scripts allow-top-navigation-by-user-activation allow-top-navigation"
  src="https://app.heimv.ch/{{organisation.slug}}/homes/{{home.id}}/occupancies/embed?display_months=9"
  border="0"
  style="width: 100%; overflow-x: hidden; overflow-y: scroll; height: 960px; border: none;">
</iframe>
```

## Add Organisation

Create a organisation with richtext templates and a user:

```
onboarding = OnboardingService.create(name: <name>, email: <email>, slug: <slug>)
onboarding.create_missing_rich_text_templates!(include_optional: true)
onboarding.add_or_invite_user!
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
- category (which corresponds to the booking category keys set for the organisation, optional)
- phone

Options:

- initial_state: State to which the booking shall be transitioned
- default_category:
- headers: Header map e.g. for import from pfadiheime.ch

```
headers = "
ignore.id,ignore.cottage_id,ignore.user_id,occupancy.begins_at,occupancy.ends_at,occupancy.remarks,occupancy.occupancy_type,ignore.created_at,ignore.updated_at,tenant.email,ignore.occupancy_type,booking.remarks,ignore.slug,booking.headcount,tenant.birth_date,booking.tenant_organisation,tenant.name,tenant.street_address,tenant.street_address_2,tenant.zipcode,tenant.city,tenant.phone"
```

Then import data with:

```
cat data.csv | bin/rails r "Import::Csv::OccupancyImporter.new(home).parse(ARGF, **options)"
```

or with heroku:

```
cat data.csv | heroku run --no-tty -- 'bin/rails r "Import::Csv::OccupancyImporter.new(home).parse"'
```

### Tenants

Prepare a csv with these columns, including a header, as utf-8:

- tenant.first_name
- tenant.last_name
- tenant.nickname
- tenant.street
- tenant.zipcode
- tenant.city
- tenant.phone
- tenant.email
- tenant.remarks

Then import data with:

```
cat data.csv | bin/rails r "Import::Csv::TenantImporter.new(organisation).parse"
```

### Tarifs

Prepare a csv with these columns, including a header, as utf-8:

- ordinal
- label
- type
- tarif_group
- unit
- price
- invoice_types

Then import data with:

```
cat data.csv | bin/rails r Import::Csv::TarifImporter.new(home).read
```

## Backup & Restore

```
cat ./path/to/backup.dump | docker exec -i $(docker ps -q --filter name=heimv-db-)  pg_restore -U postgres -d heimv_development --host=localhost --no-privileges --no-owner
```

## Copyright & License

🎂 1000th commit 🎂

Copyright 2017-2022 Diego P. Steiner & contributors

If you want to use HeimV in a commercial setting, a commercial licence
is required. For a commercial licence please get in touch: license@heimv.ch.
Other than that, the project is licensed under the AGPLv3 License.
See LICENCE for details.
