#Dockerfile
FROM ubuntu:20.04

ENV Success "Build Success!"

RUN apt-get update && apt install -yq  tzdata \
&& ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime \
&& dpkg-reconfigure -f noninteractive tzdata

# 패키지 설치
RUN apt-get install -y \
apache2 \
mariadb-client \
php7.4 libapache2-mod-php7.4 php7.4-mysql  \
wget \
vim \
net-tools \
curl \
zip

# Apache2 설정 파일 수정
RUN echo "# ServerName your_domain_or_ip" >> /etc/apache2/apache2.conf


#Wordpress 설치 및 권한 설정
RUN wget https://seyoon.s3.ap-northeast-2.amazonaws.com/latest.tar \
&& tar -tf latest.tar \
&& cp wordpress/wp-config-sample.php wordpress/wp-config.php \
&& echo "define('FS_METHOD', 'direct');" >> wordpress/wp-config.php \
&& cp -r wordpress/* /var/www/html/ \
&& chown -R www-data:www-data /var/www/html \
&& find /var/www/html/ -type d -exec chmod 755 {} \; \
&& find /var/www/html/ -type f -exec chmod 644 {} \; \
&& rm /var/www/html/index.html \
&& echo $Success

CMD ["apachectl", "-D", "FOREGROUND"]

EXPOSE 80
