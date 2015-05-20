#!/bin/bash

echo "`/usr/local/bin/contacts -s -Sf '%e:%ln %fn:%nn' $@ | \\
awk -F':' '{printf $1 "\t" $2 "\t" $3 "\n"}'`"
