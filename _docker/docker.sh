#!/usr/bin/env bash

cd /var/www/update.blog/ && nohup sh -c node_modules/.bin/gulp &

nohup sh -c php-fpm &

/usr/local/bin/caddy -conf /etc/caddy/Caddyfile