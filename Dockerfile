FROM ubuntu
RUN apt-get update -y
RUN apt-get nginx -y
RUN rm -f /var/www/html/*
COPY . /var/www/html/
EXPOSE 8080
CMD ["nginx" "-g" "daemon off;"]