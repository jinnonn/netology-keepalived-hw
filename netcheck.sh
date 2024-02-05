#!/bin/bash

curl localhost &> /dev/null
if [ "$?" -ne 0 ]; then exit 1; fi
if [ ! -f "/var/www/html/index.nginx-debian.html" ]; then exit 1; fi