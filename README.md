# HeimV Heimverwaltung

![HeimV Logo](app/javascript/images/logo.png)

## Development

```sh
git clone git@github.com:diegosteiner/heimv.git
cd heimv
docker-compose up app
```

or with VS Code: [Reopen in Container] with Remote Containers Extension

### Development servers

Then inside the container you may run:

- `bin/rails s` to start rails server
- `bin/vite dev` to start vite dev server
- `bin/jobs` to start the active job worker process

To visit the automatically created default organization, visit <http://heimv.localhost:3000/>.

### Login

After starting the development servers, open the browser <http://heimv.localhost:3000/> and log in with:

- Manager: <manager@heimv.local>, heimverwaltung
- Read only user: <reader@heimv.local>, heimverwaltung

### Commands

- Setup DB: `bin/rails db:prepare`
- Run migrations: `bin/rails db:migrate`
- Run checks: `bin/check`
- Run e2e Tests: `bin/e2e`

### Configuration

Copy env.example to .env and change configuration there

## Embed Calendar for an Occupiable

```html
<iframe
  sandbox="allow-same-origin allow-scripts allow-top-navigation-by-user-activation allow-top-navigation"
  src="https://app.heimv.ch/{{organisation.slug}}/occupiables/{{occupiables.id}}/calendar/embed?display_months=9"
  style="width: 100%; overflow-x: hidden; overflow-y: scroll; height: 960px; border: none;">
  border="0"
</iframe>
```

## Embed Calendar for a Home

```html
<iframe
  sandbox="allow-same-origin allow-scripts allow-top-navigation-by-user-activation allow-top-navigation"
  src="https://app.heimv.ch/{{organisation.slug}}/homes/{{home.id}}/occupancies/embed?display_months=9"
  border="0"
  style="width: 100%; overflow-x: hidden; overflow-y: scroll; height: 960px; border: none;">
</iframe>
```

## Embed via ICAL

Use this feed in a ICAL compatible calendar app:

<https://app.heimv.ch/{{organisation.slug}}/occupiables/{{occupiable.id}}/calendar.ics>

Use this feed to get more info (token required)

<https://app.heimv.ch/{{organisation.slug}}/occupiables/{{occupiable.id}}/calendar/private_ical_feed.ics?token={{token}}>

The token can be generated with `user.regenerate_token`

## Add Organisation

Create a organisation with richtext templates and a user:

```ruby
onboarding = OnboardingService.create(name: <name>, email: <email>, slug: <slug>)
onboarding.create_missing_rich_text_templates!(include_optional: true)
onboarding.add_or_invite_user!
```

## Translations

Translations are driven by [translation.io](https://translation.io/) and their free service for opensource projects.

## Cronjobs

Automatically change after some time has passed:

```bash
bin/rails r TransitionBookingStatesJob.perform_now
```

Resend failed Notification attemps:

```bash
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

```ruby
headers = "
ignore.id,ignore.cottage_id,ignore.user_id,booking.begins_at,booking.ends_at,booking.remarks,booking.occupancy_type,ignore.created_at,ignore.updated_at,tenant.email,ignore.occupancy_type,booking.remarks,ignore.slug,booking.headcount,tenant.birth_date,booking.tenant_organisation,tenant.name,tenant.street_address,tenant.street_address_2,tenant.zipcode,tenant.city,ignore,ignore,ignore,ignore,tenant.phone"
```

Then import data with:

```bash
cat data.csv | bin/rails r "Import::Csv::BookingImporter.new(home).parse(ARGF, **options)"
```

or with heroku:

```bash
cat data.csv | heroku run --no-tty -- 'bin/rails r "Import::Csv::BookingImporter.new(home).parse"'
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

```bash
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
- associated_types

Then import data with:

```bash
cat data.csv | bin/rails r Import::Csv::TarifImporter.new(home).read
```

## Backup & Restore

```bash
cat ./path/to/backup.dump | docker exec -i $(docker ps -q --filter name=heimv-db-)  pg_restore -U postgres --dbname heimv_development --host=localhost --no-privileges --no-owner --no-acl --clean --create --verbose
```

## Copyright & License

Copyright 2017-2025 Diego P. Steiner & contributors

If you want to use HeimV in a commercial setting, a commercial licence
is required. For a commercial licence please get in touch: <license@heimv.ch>.
Other than that, the project is licensed under the AGPLv3 License.
See LICENCE  for details.

- 1st commit 15.06.2017
- 1000th commit 🎂 26.12.2020
- 2000th commit 🎂🎂 25.04.2023
- 3000th commit 🎂🎂🎂 10.05.2025
