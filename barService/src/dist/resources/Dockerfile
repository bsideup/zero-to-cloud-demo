FROM java:8-jre

RUN curl -L https://github.com/zeroturnaround/configo/releases/download/v0.4.0/configo.linux-amd64 > /usr/local/bin/configo && \
    chmod +x /usr/local/bin/configo

ADD app.jar /app/app.jar

ENV LOGGER_OPTS -s

CMD ["configo", "bash -c 'java $JAVA_OPTS -jar /app/app.jar &> >(logger $LOGGER_OPTS)'"]

EXPOSE 8080