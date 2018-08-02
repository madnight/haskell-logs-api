FROM pritunl/archlinux:2018-05-19 as builder

RUN pacman -S --noconfirm wget python python-pip gcc

RUN pip3 install csvs-to-sqlite datasette

RUN mkdir /download
WORKDIR /download
COPY download.sh /download

RUN bash download.sh "haskell"    && \
    bash download.sh "haskell-13" && \
    bash download.sh "haskell-14" && \
    bash download.sh "haskell-15" && \
    bash download.sh "haskell-16" && \
    bash download.sh "haskell-17"


FROM python:3.6-slim-stretch as datasette
RUN apt update && \
    apt install -y python3-dev gcc libsqlite3-mod-spatialite && \
    pip3 install datasette

FROM python:3.6-slim-stretch

# Copy python dependencies and spatialite libraries
COPY --from=builder /download/irc-logs.db /irc-logs.db

# Copy python dependencies
COPY --from=datasette /usr/local/lib/python3.6/site-packages /usr/local/lib/python3.6/site-packages
# Copy executables
COPY --from=datasette /usr/local/bin /usr/local/bin
# Copy spatial extensions
COPY --from=datasette /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu

EXPOSE 8001

CMD datasette serve -h 0.0.0.0 --cors --config sql_time_limit_ms:30000 /irc-logs.db
