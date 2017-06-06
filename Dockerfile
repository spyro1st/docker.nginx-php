FROM debian:jessie

MAINTAINER info@digitalpatrioten.com

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq && apt-get install -qqy wget

RUN echo "Europe/Berlin" > /etc/timezone
RUN dpkg-reconfigure -f noninteractiv tzdata

RUN wget http://www.dotdeb.org/dotdeb.gpg
RUN apt-key add dotdeb.gpg
RUN rm -rf dotdeb.gpg

RUN echo "deb http://ftp.hosteurope.de/mirror/packages.dotdeb.org/ jessie all" >> /etc/apt/sources.list
RUN echo "deb-src http://ftp.hosteurope.de/mirror/packages.dotdeb.org/ jessie all" >> /etc/apt/sources.list

RUN apt-get update -qq && \
    apt-get install -qqy python-setuptools supervisor openssh-server bzip2 git curl procps cron unzip nginx-extras mysql-client vim-tiny libpcre3 php7.0 php7.0-cli php7.0-common php7.0-mbstring php7.0-intl php7.0-curl php7.0-fpm php7.0-gd php7.0-imagick php7.0-mcrypt php7.0-memcached php7.0-mysql php-pear php7.0-xml php7.0-xsl php7.0-soap php7.0-xdebug php7.0-zip graphicsmagick ssl-cert ssmtp && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    sed -i 's/;date.timezone =/date.timezone = "Europe\/Berlin"/g' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/memory_limit = 128M/memory_limit = 256M/g' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/max_execution_time = 30/max_execution_time = 240/g' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 20M/g' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/g' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/display_errors = Off/display_errors = On/g' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/; max_input_vars = 1000/max_input_vars = 1500/g' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/;daemonize = yes/daemonize =  no/g' /etc/php/7.0/fpm/php-fpm.conf && \
    sed -i 's/;error_log = php_errors.log/error_log = \/var\/log\/php_error.log/g' /etc/php/7.0/fpm/php.ini && \
    sed -i 's/listen = \/run\/php\/php7.0-fpm.sock/listen = \/var\/run\/php-fpm.sock/g' /etc/php/7.0/fpm/pool.d/www.conf && \
    echo 'xdebug.max_nesting_level = 1000' >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini && \
    echo 'xdebug.idekey = PHPSTORM' >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini && \
    echo 'xdebug.remote_enable = 1' >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini && \
    echo 'xdebug.remote_connect_back = 1' >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini

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