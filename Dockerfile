# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# System fisrt update
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y software-properties-common

# System setup
RUN \
  # add apache apt external repositories
  add-apt-repository -y ppa:ondrej/apache2 \
  # add php apt external repository
  && add-apt-repository -y ppa:ondrej/php \
  # add git apt external repository
  && add-apt-repository -y ppa:git-core/ppa \
  # update apt packages list
  && apt-get update \
  # install required apt packages
  && apt-get install -y \
  # - apt packages for System
  zip unzip cron curl wget sudo nano \
  # - apt packages for Apache
  apache2 libapache2-mod-security2 \
  # - apt packages for mysql client
  mysql-client \
  # - apt packages for PHP
  php7.4 php7.4-bcmath php7.4-common php7.4-curl php7.4-xml php7.4-gd php7.4-intl php7.4-mbstring php7.4-mysql php7.4-soap php7.4-zip php7.4-imagick php7.4-mcrypt php7.4-ssh2 \
  # - apt packages for GIT
  git git-core bash-completion \
  # enable apache modules
  && a2enmod deflate expires headers rewrite security2 ssl proxy_http \
  # umask setup
  && echo "umask 0002" >> /etc/profile \
  && echo "umask 0002" >> /etc/bash.bashrc \
  # wordpress user setup
  && groupadd --gid 1000 wpuser \
  && useradd --uid 1000 --gid wpuser --create-home wpuser \
  && usermod --shell /bin/bash wpuser \
  && usermod -aG sudo wpuser \
  && passwd -d wpuser \
  && gpasswd -a wpuser www-data \
  # install wp-cli
  && cd /root && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp \
  && wget https://raw.githubusercontent.com/wp-cli/wp-cli/main/utils/wp-completion.bash \
  && chown wpuser:wpuser /root/wp-completion.bash \
  && mv /root/wp-completion.bash /home/wpuser/

# User config
USER wpuser
SHELL [ "/bin/bash", "-li", "-c" ]
RUN cd /home/wpuser \
  # confirm sudo user
  && touch .sudo_as_admin_successful \
  # install nvm
  && (curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash) \
  && source .bashrc \
  # install node and npm
  && nvm install 18.15.0
USER root
SHELL ["/bin/sh", "-c"]

# Copy config files
COPY ./etc/ /root/

# System config
RUN \
  # apache config
  mv /root/apache/* /etc/apache2/sites-available/ \
  && mv /var/www/html /var/www/info \
  && a2ensite 002-info-vhost.conf \
  && rm -rf /root/apache \
  # php config
  && mv /root/php/phpinfo.php /var/www/info/ \
  && bash /root/php/php-ini-conf.sh \
  && rm -rf /root/php \
  # composer config
  && bash /root/composer/composer-install.sh \
  && rm -rf /root/composer \
  # wordpress utilities
  && chmod +x /root/wp/* \
  && mv /root/wp/* /usr/local/bin/ \
  && rm -rf /root/wp \
  # set git for wordpress user
  && chown wpuser:wpuser /root/git/.bash_gitrc /root/git/.gitconfig \
  && mv /root/git/.bash_gitrc /home/wpuser/ \
  && mv /root/git/.gitconfig /home/wpuser/ \
  && rm -rf /root/git \
  # set aliases for wordpress user
  && chown wpuser:wpuser /root/user/.bash_aliases \
  && mv /root/user/.bash_aliases /home/wpuser/ \
  && rm -rf /root/user

# Container config
WORKDIR /wp-app
EXPOSE 80
CMD [ "apachectl", "-D", "FOREGROUND" ]
