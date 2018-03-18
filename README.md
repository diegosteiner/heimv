# Heimverwaltung

## Environments

| Branch  | Domain                                | Deployment | CI                                      |
| ------- | ------------------------------------- | ---------- | --------------------------------------- |
| develop | https://heimverwaltung-develop.herokuapp.com | auto       | [![Build Status](https://semaphoreci.com/api/v1/projects/87b971b5-ffa5-46f9-8a5d-c9e5cb19fa2d/1371806/badge.svg)](https://semaphoreci.com/pfadiheime/heimverwaltung)|
| master  | https://heimverwaltung-master.herokuapp.com  | release    | [![Build Status]()](https://semaphoreci.com/pfadiheime/heimverwaltung)  |

## Prequisites

You'll need at least:

* A working ruby >= 2.4.2 installation
* A working node >= 9.2.0 installation

## Setup

```sh
git clone git@github.com:diegosteiner/heimverwaltung.git
cd heimverwaltung
bin/setup
```

### Configuration

Configure the following:

* .env

### Run

For development run:

```sh
bin/run dev
```

### Tests / Checks

```sh
bin/check
```

## Copyright

Coypright 2017 Diego P. Steiner
MIT License
