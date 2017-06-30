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
        echo "Linking default site if not exist"
        if [ ! -f "/etc/nginx/sites-enabled/default" ]; then
            ln -sf /etc/nginx/conf/sites/default /etc/nginx/sites-enabled/default
        fi
    fi
fi

if [[ "$OVERRIDE_DOCROOT" ]]; then
    sed -i -e "s/\/var\/www/$(echo $OVERRIDE_DOCROOT | sed -e 's/[\/&]/\\&/g')/g" base
fi

echo -e 'mailhub='$SMTP_HOST'\nAuthUser='$SMTP_USER'\nAuthPass='$SMTP_PASSWORD'\nUseSTARTTLS=yes\nUseTLS=yes\nFromLineOverride=yes' > /etc/ssmtp/ssmtp.conf

if [ ! -z "$DISABLE_XDEBUG" ]; then
    rm -rf /etc/php5/fpm/conf.d/20-xdebug.ini
    rm -rf /etc/php5/cli/conf.d/20-xdebug.ini
fi

chmod 0600 /var/spool/cron/crontabs/*
chown www-data:www-data -R /var/www
chsh -s /bin/bash www-data
