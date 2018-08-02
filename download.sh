#!/usr/bin/env bash

cd /tmp
wget -q -O - http://tunes.org/~nef/logs/old/"$1".zip \
| bsdtar -xvf- && \
sed -i '/---/d' * && \
find . -type f -empty -delete && \
find . -name '*' ! -type d -exec bash -c 'expand -t 4 "$0" > /tmp/e && mv /tmp/e "$0"' {} \; && \
awk  '{gsub(">","",$2) gsub("<","",$2);printf "%s\t%s\t%s",FILENAME,$1,$2;$1="";$2="";printf "\t%s\n", substr($0,3)}' \
`ls | grep -v "download.sh"` \
> /tmp/"$1".txt

sed -i '1s/^/date\ttime\tuser\tpost\n/' /tmp/*.txt

export LC_ALL=en_US.utf8
export LANG=en_US.utf8

csvs-to-sqlite /tmp/"$1".txt /download/irc-logs.db -s $'\t'

rm /tmp/*
