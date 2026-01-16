#!/usr/bin/env bash
PGPASSWORD="luxecart_pass" psql -h "localhost" -U "luxecart_user" -d "luxecart_development" -c '\dt'
