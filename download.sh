# IRC_LOGS=("haskell" "haskell-13" "haskell-14" "haskell-15"  "haskell-16" "haskell-17")
IRC_LOGS=("functional")

for i in "${IRC_LOGS[@]}"
do
  wget -q -O - http://tunes.org/~nef/logs/old/"$i".zip \
  | bsdtar -xvf- && \
  sed -i '/---/d' * && \
  find . -type f -empty -delete && \
  awk '{print FILENAME,$0}' `ls | grep -v "download.sh"` \
  > /tmp/irclog-"$i".txt
done
