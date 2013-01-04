#!/bin/sh
if [ $(stat -c %d ~/) -eq $(stat -c %d ~/Remote) ]; then
  sshfs simplynux.net:www ~/Remote -o uid=$(id -u) -o gid=$(id -g)
else
  echo Already connected >&2
fi
