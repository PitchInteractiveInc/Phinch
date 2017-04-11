FROM ubuntu:16.04

# Install required packages
RUN apt-get update && apt-get --assume-yes install \
    apache2 \
    git \
    php \
    curl \
    php-dev \
    php-curl \
    libapache2-mod-php \
    zip \
    nodejs \
    npm

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install bower
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN npm install -g bower

# Prepare apache
RUN rm -rf /var/www/html

# Make terminal functional by default
RUN echo "export TERM=xterm" >>/root/.bashrc

# Install biom via conda
RUN curl -sS http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh >miniconda.sh
RUN chmod +x miniconda.sh
RUN ./miniconda.sh -b -f -p /usr/local
RUN echo "export LC_ALL=C.UTF-8" >>/etc/apache2/envvars
RUN echo "export LANG=C.UTF-8" >>/etc/apache2/envvars

# Clone git repo
RUN git clone https://github.com/molbiodiv/biom-conversion-server.git /var/www/html
RUN cd /var/www/html && conda install --yes --file explicit-conda-spec.txt
RUN cd /var/www/html && composer install
RUN cd /var/www/html && bower install --allow-root

# Add custom php ini
ADD php.ini /etc/php/7.0/apache2/php.ini

CMD service apache2 start; while true; do sleep 60; done
