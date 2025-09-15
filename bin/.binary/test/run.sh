#!/bin/bash

cat data.json | jq -s 'sort_by(. syllery) | tail -n 2 | head -n 1
