#!/bin/bash

echo "`/usr/local/bin/contacts -s -Sf '%e:%fn %ln:%nn' $@ | \\
awk -F':' '{printf $1 "\t" $2 "\t" $3 "\n"}'`"
