#!/usr/bin/env bash

echo "Starting Hastebin migration..."
echo "create table entries (id bigserial primary key, key varchar(255) not null, value text not null, expiration bigint, unique(key));" | docker exec -i database-hastebin psql hastebin hastebin
echo "Done"