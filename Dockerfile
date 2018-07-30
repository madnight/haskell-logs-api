FROM pritunl/archlinux:2018-05-19

RUN pacman -S --noconfirm wget

RUN mkdir /download
WORKDIR /download
COPY download.sh /download

RUN bash download.sh
