FROM debian:jessie

MAINTAINER info@digitalpatrioten.com

RUN apt-get update -qq && apt-get install -qqy wget

RUN echo "Europe/Berlin" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN wget http://nginx.org/keys/nginx_signing.key
RUN apt-key add nginx_signing.key
RUN rm -rf nginx_signing.key

RUN echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list
RUN echo "deb-src http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list

RUN apt-get update -qq && \
    apt-get install -qqy procps cron unzip nginx mysql-client vim-tiny php5 php5-cli php5-common php5-curl php5-fpm php5-gd php5-imagick php5-mcrypt php5-memcache php5-mysqlnd php-pear php5-xsl php5-xdebug graphicsmagick ssl-cert ssmtp && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    sed -i 's/;date.timezone =/date.timezone = "Europe\/Berlin"/g' /etc/php5/fpm/php.ini && \
    sed -i 's/max_execution_time = 30/max_execution_time = 240/g' /etc/php5/fpm/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 20M/g' /etc/php5/fpm/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/g' /etc/php5/fpm/php.ini && \
    sed -i 's/display_errors = Off/display_errors = On/g' /etc/php5/fpm/php.ini && \
    sed -i 's/;error_log = syslog/error_log = \/proc\/self\/fd\/2/g' /etc/php5/fpm/php.ini && \
    sed -i 's/access_log \/var\/log\/nginx\/access.log;/access_log \/proc\/self\/fd\/2 combined;/g' /etc/nginx/nginx.conf && \
    sed -i 's/error_log \/var\/log\/nginx\/error.log;/error_log \/proc\/self\/fd\/2 error;/g' /etc/nginx/nginx.conf && \
    echo 'xdebug.max_nesting_level = 1000' >> /etc/php5/fpm/conf.d/20-xdebug.ini && \
    echo 'xdebug.idekey = PHPSTORM' >> /etc/php5/fpm/conf.d/20-xdebug.ini && \
    echo 'xdebug.remote_enable = 1' >> /etc/php5/fpm/conf.d/20-xdebug.ini && \
    echo 'xdebug.remote_connect_back = 1' >> /etc/php5/fpm/conf.d/20-xdebug.ini

ADD start.sh /start.sh

RUN chmod 0755 /start.sh

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

CMD /start.sh

EXPOSE 80 443
