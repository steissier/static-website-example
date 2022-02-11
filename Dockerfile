FROM nginx
COPY . /var/www/html/
EXPOSE 8080
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]