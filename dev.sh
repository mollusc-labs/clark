#!/bin/bash
if [ -z '.env' ]; then 
    echo 'No .env detected, please run setup.pl before anything else'
    exit 1
fi
export $(cat .env | xargs) && morbo clark.pl