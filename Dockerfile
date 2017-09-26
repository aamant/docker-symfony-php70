FROM debian:stretch

MAINTAINER Arnaud Amant <contact@arnaudamant.fr>

ENV DEBIAN_FRONTEND noninteractive

RUN apt update \
    && apt install -y \
        php-fpm php-cli php-mcrypt php-json php-intl php-mysql php-pgsql php-curl php-gd php-soap php-xml php-apcu \
        apache2 git zip unzip

RUN apt autoremove -y && rm -rf /var/lib/apt/lists/*

RUN a2enmod proxy_fcgi setenvif rewrite
RUN a2enconf php7.0-fpm

COPY symfony.conf /etc/apache2/sites-available/symfony.conf

COPY php/xdebug.ini /etc/php/7.0/mods-available/xdebug.ini
COPY php/custom.ini /etc/php/7.0/mods-available/custom.ini

RUN a2dissite 000-default
RUN a2ensite symfony

RUN phpenmod -s fpm custom
RUN phpenmod -s cli custom

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php  --install-dir=usr/local/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"

EXPOSE 80

VOLUME /sources

WORKDIR /sources

CMD /etc/init.d/php7.0-fpm start && /usr/sbin/apache2ctl -D FOREGROUND
