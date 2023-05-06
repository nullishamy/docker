_default:
  @just --list

# Show recipe help
help:
  @just --list

# Bring up all services
up:
	#!/usr/bin/env bash

	if [ ! docker network inspect traefik >/dev/null 2>&1 ] && [ ! docker network create traefik ]; then
		echo "Could not find nor create traefik network, please make it and re-run" && exit 1
	fi

	s() {
		docker compose -f $1/compose.yaml $2 $3 $4 $5
	}

	set -e 
	s traefik up -d
	s web up -d
	s gitea up -d
	s hastebin up -d
	s nextcloud up -d
	s pgadmin up -d

# Tear down all services
down:
	#!/usr/bin/env bash

	s() {
		docker compose -f $1/compose.yaml $2 $3 $4 $5
	}

	set -e 
	s traefik down
	s pgadmin down
	s web down
	s gitea down
	s hastebin down
	s nextcloud down

# Restart all services
restart: down up

# Setup the dockerfiles for the first time
setup:
	#!/usr/bin/env bash
	if [ ! docker network inspect traefik >/dev/null 2>&1 ] && [ ! docker network create traefik ]; then
		echo "Could not find nor create traefik network, please make it and re-run" && exit 1
	fi

	# Initialise hastebin schema
	docker compose -f hastebin/compose.yaml up database-hastebin
	./hastebin/init-schema.sh

	echo "You should setup Gitea's secrets (see gitea/.env.example)"
	echo "You should move Gitea's app.ini file (see gitea/conf/app.ini.example)"
	echo "You should verify there is a mount point at /mnt/blk for Nextcloud (see nextcloud/compose.yaml)"

# Display all logs
logs:
	find . -maxdepth 2 -name compose.yaml | xargs -I {} -P 30 docker compose -f {} logs --since 1m -f