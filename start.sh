#! /bin/bash
if [[ -e /firstrun ]]; then
echo "not first run so skipping initialization"
else
echo "Creating the TYPO3 database..."
echo "create database TYPO3" | mysql -u "$DB_ENV_USER" --password="$DB_ENV_PASS" -h db -P "$DB_PORT_3306_TCP_PORT"
while [ $? -ne 0 ]; do
sleep 5
echo "create database TYPO3" | mysql -u "$DB_ENV_USER" --password="$DB_ENV_PASS" -h db -P "$DB_PORT_3306_TCP_PORT"
echo "show tables" | mysql -u "$DB_ENV_USER" --password="$DB_ENV_PASS" -h db -P "$DB_PORT_3306_TCP_PORT" TYPO3
done
touch /firstrun
fi
service php5-fpm start
nginx 
