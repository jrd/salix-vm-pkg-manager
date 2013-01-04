#!/bin/sh
if [ $(stat -c %d ~/) -ne $(stat -c %d ~/Remote) ]; then
  fusermount -u ~/Remote
else
  echo Already disconnected >&2
fi
