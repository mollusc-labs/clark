#!/bin/bash
export $(cat .env | xargs) && morbo clark.pl