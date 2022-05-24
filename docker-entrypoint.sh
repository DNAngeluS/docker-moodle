#!/bin/bash
set -euo pipefail

user="${APACHE_RUN_USER:-www-data}"
group="${APACHE_RUN_GROUP:-www-data}"

	if [ ! -e index.php ] && [ ! -e version.php ]; then
		# if the directory exists and Moodle doesn't appear to be installed AND the permissions of it are root:root, let's chown it (likely a Docker-created directory)
		if [ "$(id -u)" = '0' ] && [ "$(stat -c '%u:%g' .)" = '0:0' ]; then
			chown "$user:$group" .
		fi

		echo >&2 "Moodle not found in $PWD - copying now..."
		if [ -n "$(ls -A)" ]; then
			echo >&2 "WARNING: $PWD is not empty! (copying anyhow)"
		fi
		sourceTarArgs=(
			--create
			--file -
			--directory /usr/src/moodle
			--owner "$user" --group "$group"
		)
		targetTarArgs=(
			--extract
			--file -
		)
		if [ "$user" != '0' ]; then
			# avoid "tar: .: Cannot utime: Operation not permitted" and "tar: .: Cannot change mode to rwxr-xr-x: Operation not permitted"
			targetTarArgs+=( --no-overwrite-dir )
		fi
		tar "${sourceTarArgs[@]}" . | tar "${targetTarArgs[@]}"
		echo >&2 "Complete! Moodle has been successfully copied to $PWD"
	fi
    
    # Check if moodle data directory exists and is writable
    if [ -d /var/moodle ]; then
    	if [ "$(id -u)" = '0' ] && [ "$(stat -c '%u:%g' /var/moodle)" = '0:0' ]; then
			chown -R "$user:$group" /var/moodle
		fi
    fi

echo "*/1 * * * *    /usr/local/bin/php /srv/www/moodles/admin/cli/cron.php > /dev/null" > /var/moodle/cron
crontab /var/moodle/cron

exec "$@"