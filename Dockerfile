FROM debian:wheezy

MAINTAINER info@digitalpatrioten.com

RUN apt-get update -qq && apt-get install -qqy wget

RUN wget http://www.dotdeb.org/dotdeb.gpg
RUN apt-key add dotdeb.gpg
RUN rm -rf dotdeb.gpg

RUN echo "deb http://dotdeb.netmirror.org/ stable all" >> /etc/apt/sources.list
RUN echo "deb-src http://dotdeb.netmirror.org/ stable all" >> /etc/apt/sources.list

RUN apt-get update -qq && \
    apt-get install -qqy unzip nginx mysql-client vim-tiny php5 php5-cli php5-common php5-curl php5-fpm php5-gd php5-imagick php5-mcrypt php5-memcache php5-mysql graphicsmagick && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    sed -i 's/max_execution_time = 30/max_execution_time = 240/g' /etc/php5/fpm/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 20M/g' /etc/php5/fpm/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/g' /etc/php5/fpm/php.ini && \
    echo 'xdebug.max_nesting_level = 1000' >> /etc/php5/fpm/conf.d/20-xdebug.ini && \
    echo 'xdebug.idekey = PHPSTORM' >> /etc/php5/fpm/conf.d/20-xdebug.ini && \
    echo 'xdebug.remote_enable = 1' >> /etc/php5/fpm/conf.d/20-xdebug.ini && \
    echo 'xdebug.remote_connect_back = 1' >> /etc/php5/fpm/conf.d/20-xdebug.ini

ADD start.sh /start.sh

RUN chmod 0755 /start.sh

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

CMD /start.sh
