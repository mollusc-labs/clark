#!/bin/bash
export $(cat .env | xargs) && if [ -x 'morbo' ]; then
    morbo clark.pl
else
    perl clark.pl daemon
fi