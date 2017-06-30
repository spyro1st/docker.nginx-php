FROM debian:jessie

MAINTAINER info@digitalpatrioten.com

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq && apt-get install -qqy wget

RUN echo "Europe/Berlin" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update -qq && \
    apt-get install -qqy locales python-setuptools supervisor openssh-server bzip2 git curl procps cron unzip nginx-extras mysql-client vim-tiny php5 php5-cli php5-common php5-intl php5-curl php5-fpm php5-gd php5-imagick php5-mcrypt php5-memcache php5-mysqlnd php-pear php5-xsl php5-xdebug graphicsmagick ssl-cert ssmtp && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    sed -i 's/;date.timezone =/date.timezone = "Europe\/Berlin"/g' /etc/php5/fpm/php.ini && \
    sed -i 's/;date.timezone =/date.timezone = "Europe\/Berlin"/g' /etc/php5/cli/php.ini && \
    sed -i 's/max_execution_time = 30/max_execution_time = 240/g' /etc/php5/fpm/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 20M/g' /etc/php5/fpm/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/g' /etc/php5/fpm/php.ini && \
    sed -i 's/display_errors = Off/display_errors = On/g' /etc/php5/fpm/php.ini && \
    sed -i 's/;error_log = syslog/error_log = \/proc\/self\/fd\/2/g' /etc/php5/fpm/php.ini && \
    sed -i 's/;always_populate_raw_post_data = -1/always_populate_raw_post_data = -1/g' /etc/php5/fpm/php.ini && \
    sed -i 's/access_log \/var\/log\/nginx\/access.log;/access_log \/proc\/self\/fd\/2 combined;/g' /etc/nginx/nginx.conf && \
    sed -i 's/error_log \/var\/log\/nginx\/error.log;/error_log \/proc\/self\/fd\/2 error;/g' /etc/nginx/nginx.conf && \
    sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = \/var\/run\/php-fpm.sock/g' /etc/php5/fpm/pool.d/www.conf && \
    echo 'xdebug.max_nesting_level = 1500' >> /etc/php5/fpm/conf.d/20-xdebug.ini && \
    echo 'xdebug.idekey = PHPSTORM' >> /etc/php5/fpm/conf.d/20-xdebug.ini && \
    echo 'xdebug.remote_enable = 1' >> /etc/php5/fpm/conf.d/20-xdebug.ini && \
    echo 'xdebug.remote_connect_back = 1' >> /etc/php5/fpm/conf.d/20-xdebug.ini

RUN cp /usr/share/i18n/SUPPORTED /etc/locale.gen
RUN locale-gen

# Supervisor Config
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout

COPY ./supervisord.conf /etc/supervisor/conf.d/supervisor.conf
COPY ./start.sh /start.sh

RUN mkdir -p /var/run/sshd /var/www/.ssh /var/run/php
RUN chown -R www-data:www-data /var/www

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

VOLUME /var/www

CMD ["/usr/bin/supervisord"]

EXPOSE 22 80 443