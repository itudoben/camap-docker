FROM mysql:5.7-debian
COPY ./camap-ts/docker-compose/mysql/my.cnf /etc/mysql/conf.d/
ENV TZ="Europe/Paris" 
RUN echo "Europe/Paris" > /etc/timezone
