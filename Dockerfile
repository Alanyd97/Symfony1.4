###
### PHP-FPM 5.4
###
FROM centos:7
MAINTAINER "cytopia" <cytopia@everythingcli.org>


###
### Labels
###
LABEL \
	name="cytopia's PHP-FPM 5.4 Image" \
	image="php-fpm-5.4" \
	vendor="cytopia" \
	license="MIT" \
	build-date="2017-09-09"


###
### Envs
###

# User/Group
ENV MY_USER="devilbox" \
	MY_GROUP="devilbox" \
	MY_UID="1000" \
	MY_GID="1000"

# User PHP config directories
ENV MY_CFG_DIR_PHP_CUSTOM="/etc/php-custom.d"

# Log Files
ENV MY_LOG_DIR="/var/log/php" \
	MY_LOG_FILE_XDEBUG="/var/log/php/xdebug.log" \
	MY_LOG_FILE_ACC="/var/log/php/www-access.log" \
	MY_LOG_FILE_ERR="/var/log/php/www-error.log" \
	MY_LOG_FILE_SLOW="/var/log/php/www-slow.log" \
	MY_LOG_FILE_FPM_ERR="/var/log/php/php-fpm.err"


###
### Install
###
RUN \
	groupadd -g ${MY_GID} -r ${MY_GROUP} && \
	adduser -u ${MY_UID} -m -s /bin/bash -g ${MY_GROUP} ${MY_USER}

# Add repository and keys
RUN \
	yum -y update && \
	yum groupinstall -y "Development Tools" && \
	yum -y install deltarpm && \
	yum -y install kernel-devel && \
	yum -y install epel-release && \
	rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi && \
	rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
	yum-config-manager --enable extras && \
	yum-config-manager --enable epel && \
	yum-config-manager --enable remi && \
	yum-config-manager --disable remi-php55 && \
	yum-config-manager --disable remi-php56 && \
	yum-config-manager --disable remi-php70 && \
	yum-config-manager --disable remi-php71 && \
	yum clean all && \
	yum remove -y mariadb-libs-5.5.47-1.el7_2.x86_64 

# Install packages
RUN yum -y update && \
	while true; do \
		if yum -y install \
		httpd \	
		php \
		php-cli \
		php-devel \
		php-fpm \
		\
		php-bcmath \
		php-common \
		php-gd \
		php-gmp \
		php-imap \
		php-intl \
		php-ldap \
		php-magickwand \
		php-mbstring \
		php-mcrypt \
		php-mysql \
		php-opcache \
		php-pdo \
		php-pear \
		php-pgsql \
		php-phalcon2 \
		php-pspell \
		php-recode \
		php-redis \
		php-soap \
		php-tidy \
		php-xml \
		php-xmlrpc \
		\
		php-pecl-amqp \
		php-pecl-apcu \
		php-pecl-imagick \
		php-pecl-memcache \
		php-pecl-memcached \
		php-pecl-uploadprogress \
		php-pecl-xdebug \
		MariaDB-client \
		\
		postfix \
		\
		socat \
		\
		; then \
			break; \
		else \
			yum clean metadata && \
			yum clean all && \
			(rm /var/cache/yum/x86_64/7/timedhosts 2>/dev/null || true) && \
			(rm /var/cache/yum/x86_64/7/timedhosts.txt 2>/dev/null || true) && \
			yum -y update; \
		fi \
	done \
	\
	&& \
	\
	echo "listo"

###
### Install Tools
###
RUN yum -y update && \
	while true; do \
		if yum -y install \
		ack \
		aspell \
		autoconf \
		automake \
		bash-completion \
		bash-completion-extras \
		bind-utils \
		bzip2 \
		coreutils \
		devscripts-minimal \
		dos2unix \
		file \
		gcc \	
		git \
		hostname \
		htop \
		ImageMagick \
		ImageMagick-devel \
		iputils \
		moreutils \
		python2-pip \
		ruby-devel \
		rubygems \
		sudo \
		tig \
		vi \
		vim \
		wget \
		which \
		whois \
		; then \
			break; \
		else \
			yum clean metadata && \
			yum clean all && \
			(rm /var/cache/yum/x86_64/7/timedhosts 2>/dev/null || true) && \
			(rm /var/cache/yum/x86_64/7/timedhosts.txt 2>/dev/null || true) && \
			yum -y update; \
		fi \
	done \
	\
	&& \
	\
	yum install -y mod_ssl openssl && \
	yum -y autoremove && \
	yum clean metadata && \
	yum clean all && \
	(rm /var/cache/yum/x86_64/7/timedhosts 2>/dev/null || true) && \
	(rm /var/cache/yum/x86_64/7/timedhosts.txt 2>/dev/null || true)

#RUN timedatectl set-timezone America/Argentina/Buenos_Aires

RUN echo "extension=imagick.so" > /etc/php.d/imagick.ini
RUN echo 'xdebug.remote_enable = on' | sudo tee --append /etc/php.d/xdebug.ini
RUN echo 'xdebug.remote_connect_back = on' | sudo tee --append  /etc/php.d/xdebug.ini

# Composer
RUN \
	curl -sS https://getcomposer.org/installer | php && \
	mv composer.phar /usr/local/bin/composer && \
	composer self-update

###
### Generate locals
###
RUN \
	localedef -i es_ES -f UTF-8 es_ES.UTF-8 

###
### Ports
###
EXPOSE 80
EXPOSE 8080

RUN mkdir -p /proyectos/

COPY ./.confFigaro/php.ini /etc/php.ini

###
### Volumes
###
VOLUME /etc/php-custom.d
VOLUME /var/mail
VOLUME /proyectos

	
# Simple startup script to avoid some issues observed with container restart
RUN rm -rf /run/httpd/* /tmp/httpd*
#RUN exec /usr/sbin/apachectl -DFOREGROUND &
#CMD ["exec", "/usr/sbin/httpd", "-D", "FOREGROUND"]
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]
