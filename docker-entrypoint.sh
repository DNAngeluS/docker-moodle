#!/bin/bash
set -euo pipefail

cp -r /usr/src/moodle /app
chown -R root:www-data /app /data
chmod -R 775 /app/moodle /data
rmdir /var/www/html
ln -s /app/moodle /var/www/html
echo "* * * * *    /usr/bin/php /var/www/html/admin/cli/cron.php > /dev/null" > /app/cron
crontab /app/cron

exec "$@"
