#! /bin/bash
if [ -d /var/etc/nginx ]; then
	ln -sf /var/etc/nginx /etc/nginx/conf
	if [ ! -z "$SITES_CONFIGS" ]; then
		unlink /etc/nginx/sites-enabled/default
		IFS=","
		SITES=($SITES_CONFIGS)
		for x in "${SITES[@]}"
		do
			if [ -f "/etc/nginx/conf/sites/$x" ]; then
				echo "Linking site $x"
				ln -sf "/etc/nginx/conf/sites/$x" "/etc/nginx/sites-enabled/$x"
			fi
		done
	else
		echo "Linking default site"
		ln -sf /etc/nginx/conf/sites/default /etc/nginx/sites-enabled/default
	fi
fi
service php5-fpm start
nginx
