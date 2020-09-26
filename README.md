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

### Tasks

These commands need to be run un container

- Setup DB: `bin/rails db:prepare`
- Run migrations: `bin/rails db:migrate`
- Run checks: `bin/check`
- Run e2e Tests: `bin/e2e`

### Configuration

Copy env.example to .env and change configuration there

## Copyright & License

Coypright 2017 Diego P. Steiner

You must ask for permission before using the project in a commercial setting. Other than that, the project is licensed under the AGPL License.
