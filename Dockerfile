# Dockerfile
FROM wordpress:latest

# Copy any custom configuration or plugins if necessary
# COPY ./wp-content/ /var/www/html/wp-content/

# Set environment variables
ENV WORDPRESS_DB_HOST=db:3306
ENV WORDPRESS_DB_USER=user
ENV WORDPRESS_DB_PASSWORD=password
ENV WORDPRESS_DB_NAME=wordpress

# Expose port 80
EXPOSE 80

# When the container starts, WordPress will be running on port 80
CMD ["apache2-foreground"]
