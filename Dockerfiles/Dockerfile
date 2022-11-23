FROM perl:threaded

ENV TERM xterm

COPY . /app

WORKDIR /app

RUN perl src/plugins/perl-base/scripts/installer.pl

ENV HOME /app

ENTRYPOINT [ "process" ]

CMD ["sleep", "infinity"]
