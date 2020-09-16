#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
./new.sh > a.json
curl -i -X POST -H "Content-Type: application/json" -d @a.json http://192.168.31.130:8000/api/
