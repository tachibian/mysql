#Dockerfile for mysql-5.6.31

FROM skcho4docker/mysql-5.6.31:ver0.0.2
MAINTAINER Sangki Cho
ADD start.sh /home/mysql/start.sh
RUN chown mysql:mysql /home/mysql/start.sh; chmod 755 /home/mysql/start.sh
ENV HOME /home/mysql
USER mysql
WORKDIR /home/mysql
EXPOSE 3306
ENTRYPOINT ["/bin/bash","/home/mysql/start.sh"]
CMD ["exec"]

