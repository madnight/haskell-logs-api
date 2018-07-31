FROM pritunl/archlinux:2018-05-19

RUN pacman -S --noconfirm wget python python-pip gcc

RUN pip3 install csvs-to-sqlite datasette

RUN mkdir /download
WORKDIR /download
COPY download.sh /download

RUN bash download.sh

RUN export LC_ALL=en_US.utf8 && \
    export LANG=en_US.utf8   && \
    ls -la                   && \
    csvs-to-sqlite /tmp/*.txt irc-logs.db -s $'\t'

EXPOSE 8001

CMD export LC_ALL=en_US.utf8 && \
    export LANG=en_US.utf8   && \
    datasette serve -h 0.0.0.0 --cors --config sql_time_limit_ms:30000 irc-logs.db
