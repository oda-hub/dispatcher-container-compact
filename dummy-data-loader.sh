#!/bin/bash

mkdir -p /data
cd /data
curl https://raw.githubusercontent.com/oda-hub/dispatcher-integral-dummy-data/main/dispatcher-plugin-integral-data-dummy_prods-default.tgz | tar xzvf - --strip-components 1
mkdir -p dummy_prods
curl -o dummy_prods/query_spiacs_lc.txt  https://raw.githubusercontent.com/oda-hub/dispatcher-plugin-integral-all-sky/master/dummy_prods/query_spiacs_lc.txt
