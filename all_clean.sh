#!/bin/bash
echo "##################################################"
echo "ENTER:" $(date)
#DEBUG=echo
#PYTHON=/home/shin/anaconda3/bin/python
#PYTHON=/home/ubuntu/anaconda3/bin/python

JMA_PATH=~/Documents/python/jma_pull
#JMA_PATH=/home/ubuntu/jma_pull
for x in pdf png txt xml latest; do
  $DEBUG rm ${JMA_PATH}/$x/*
done

echo "##################################################"
echo "LEAVE:" $(date)
exit 0

