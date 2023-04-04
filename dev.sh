#!/bin/bash
if [ -z '.env' ]; then 
    echo 'No .env detected, creating one'
    perl ./make-env.pl
fi
export $(cat .env | xargs) && morbo clark.pl