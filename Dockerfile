# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# System config
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y software-properties-common zip unzip cron curl wget

# User config
RUN echo "umask 0002" >> /etc/profile \
  && echo "umask 0002" >> /etc/bash.bashrc \
  && groupadd --gid 1000 wpuser \
  && useradd --uid 1000 --gid wpuser --create-home wpuser \
  && touch /home/wpuser/.bash_aliases \
  && chown wpuser:wpuser /home/wpuser/.bash_aliases

# Apache config
COPY ./etc/apache/* /home/wpuser/
RUN add-apt-repository -y ppa:ondrej/apache2 \
  && apt-get update \
  && apt-get install -y apache2 libapache2-mod-security2 \
  && a2enmod deflate expires headers rewrite security2 ssl proxy_http \
  && gpasswd -a wpuser www-data \
  && mv /home/wpuser/*.conf /etc/apache2/sites-available/ \
  && a2ensite info-vhost.conf \
  && mv /var/www/html /var/www/info

# PHP config
COPY ./etc/php/* /home/wpuser/
RUN add-apt-repository -y ppa:ondrej/php \
  && apt-get update \
  && apt-get install -y php7.4 php7.4-bcmath php7.4-common php7.4-curl php7.4-xml php7.4-gd php7.4-intl php7.4-mbstring php7.4-mysql php7.4-soap php7.4-zip php7.4-imagick php7.4-mcrypt php7.4-ssh2 \
  && bash /home/wpuser/php-ini-conf.sh \
  && rm -fv /home/wpuser/php-ini-conf.sh \
  && mv /home/wpuser/phpinfo.php /var/www/info/

# Composer config
COPY ./etc/composer/* /home/wpuser/
RUN bash /home/wpuser/composer-install.sh \
  && rm -fv /home/wpuser/composer-install.sh

# Git config
COPY --chown=wpuser:wpuser --chmod=644 ./etc/git/* /home/wpuser/
RUN add-apt-repository -y ppa:git-core/ppa \
  && apt-get update \
  && apt-get install -y git git-core bash-completion \
  && echo '[ -f ~/git-style.sh ] && source ~/git-style.sh' >>/home/wpuser/.bash_aliases

# Node and NPM
USER wpuser
SHELL ["/bin/bash", "--login", "-i", "-c"]
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
RUN source /home/wpuser/.bashrc \
  && nvm install 18.15.0
SHELL ["/bin/bash", "--login", "-c"]

# wpuser extra utilities
USER root
COPY --chmod=755 ./etc/wp/wpperms /usr/local/bin/

# WP-CLI
RUN cd /home/wpuser \
  && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wp \
  && wget https://raw.githubusercontent.com/wp-cli/wp-cli/main/utils/wp-completion.bash \
  && echo '[ -f ~/wp-completion.bash ] && source ~/wp-completion.bash' >>/home/wpuser/.bash_aliases

# MySQL Client
RUN apt-get update \
  && apt-get install -y mysql-client

# Container config
WORKDIR /wp-app
EXPOSE 80
CMD [ "apachectl", "-D", "FOREGROUND" ]
