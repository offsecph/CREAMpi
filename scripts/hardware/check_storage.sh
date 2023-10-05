#!/bin/bash
#
# Checks the current storage of rasberry pi
#

function main {
  df -h
  echo
  df -h | grep /root -B1
  echo
  duf
}

main
