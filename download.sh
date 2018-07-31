# IRC_LOGS=("haskell" "haskell-13" "haskell-14" "haskell-15"  "haskell-16" "haskell-17")
IRC_LOGS=("functional")

for i in "${IRC_LOGS[@]}"
do
  wget -q -O - http://tunes.org/~nef/logs/old/"$i".zip \
  | bsdtar -xvf- && \
  sed -i '/---/d' * && \
  find . -type f -empty -delete && \
  find . -name '*' ! -type d -exec bash -c 'expand -t 4 "$0" > /tmp/e && mv /tmp/e "$0"' {} \; && \
  awk  '{gsub(">","",$2) gsub("<","",$2);printf "%s\t%s\t%s",FILENAME,$1,$2;$1="";$2="";printf "\t%s\n", substr($0,3)}' \
  `ls | grep -v "download.sh"` \
  > /tmp/irclog-"$i".txt && \
  sed -i '1s/^/date\ttime\tuser\tpost\n/' /tmp/*
done
