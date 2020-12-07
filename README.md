# Heimverwaltung

## Setup with Docker

```sh
git clone git@github.com:diegosteiner/heimv.git
cd heimv
docker-compose up app
```

or with VS Code

- Start in Container with Remote Containers Extension
- Start Server with [F5] Debug

To visit the automatically created default organization, visit http://localhost:3000/.

To manage your organizations, visit http://localhost:3000/admin and log in with username `admin@heimv.local` and password `heimverwaltung`.

### Tasks

These commands need to be run un container

- Setup DB: `bin/rails db:prepare`
- Run migrations: `bin/rails db:migrate`
- Run checks: `bin/check`
- Run e2e Tests: `bin/e2e`

### Configuration

Copy env.example to .env and change configuration there

## Embed

```
<iframe style="width: 100%; overflow: hidden; height: 1300px; border: none;" sandbox="allow-same-origin allow-scripts allow-top-navigation-by-user-activation allow-top-navigation" src="https://app.heimv.ch/{organisation.slug}/homes/{home.id}/occupancies/embed?display_months=9" border="0">
</iframe>
```

## Copyright & License

Coypright 2017 Diego P. Steiner & contributors

If you want to use HeimV in a commercial setting, a commercial licence
is required. For a commercial licence please get in touch: license@heimv.ch. 
Other than that, the project is licensed under the AGPLv3 License. 
See LICENCE for details.
