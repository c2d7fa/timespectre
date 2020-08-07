FROM archlinux:latest

RUN pacman --noconfirm -Syu
RUN pacman --noconfirm -S elixir
RUN pacman --noconfirm -S git
RUN pacman --noconfirm -S base-devel

RUN \
  pacman --noconfirm -S sudo && \
  useradd user -m && \
  passwd -d user && \
  echo "user ALL=(ALL) ALL" >>/etc/sudoers

WORKDIR /home/user
RUN \
  sudo -u user git clone https://aur.archlinux.org/yay.git && \
  cd yay && \
  sudo -u user makepkg -si --noconfirm

RUN sudo -u user yay --noconfirm -S elm-platform-bin
RUN sudo -u user yay --noconfirm -S elm-format elm-test

RUN pacman --noconfirm -S npm
RUN npm install -g sass

RUN pacman --noconfirm -S tmux

RUN alias ls='ls --color -F'
WORKDIR /work
