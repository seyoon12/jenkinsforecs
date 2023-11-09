FROM ubuntu:20.04

ENV Success "Build Success!"

RUN apt-get update && apt install -yq tzdata \
&& ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime \
&& dpkg-reconfigure -f noninteractive tzdata

# 패키지 설치
RUN apt-get install -y \
apache2 \
mariadb-client \
php7.4 libapache2-mod-php7.4 php7.4-mysql \
wget \
vim \
net-tools \
curl \
zip

# Create the apache2 run directory
RUN mkdir -p /var/run/apache2 && chown -R www-data:www-data /var/run/apache2

# Wordpress 설치 및 권한 설정
RUN wget https://seyoon.s3.ap-northeast-2.amazonaws.com/wwwroot.zip
RUN unzip wwwroot.zip \
&& cp -r wwwroot/* /var/www/html/ \
&& chown -R www-data:www-data /var/www/html \
&& find /var/www/html/ -type d -exec chmod 755 {} \; \
&& find /var/www/html/ -type f -exec chmod 644 {} \; \
&& rm /var/www/html/index.html \
&& echo $Success

CMD ["apachectl", "-D", "FOREGROUND"]

EXPOSE 80
