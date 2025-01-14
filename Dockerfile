FROM ubuntu
RUN apt-get update -y
RUN apt-get install nginx -y
RUN rm -f /var/www/html/*
COPY . /var/www/html/
EXPOSE 80
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]