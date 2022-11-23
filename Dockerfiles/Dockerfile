FROM perl:threaded

ENV TERM xterm

COPY . /app

WORKDIR /app

RUN perl /app/src/plugins/perl-base/Dockerfiles/installer.pl

ENV HOME /app

ENTRYPOINT [ "process" ]

CMD ["sleep", "infinity"]
