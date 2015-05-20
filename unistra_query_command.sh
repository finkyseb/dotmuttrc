#!/bin/sh
# Requires: echo, expr, grep, ldapsearch, sed, test
# Set your PATH accordingly.
#

max=100
timeout=60
sort=givenName
username='virgile.gerecke'
uid=`echo "uid=$username,o=uds"`
password=`security find-generic-password -a "$username" -w`
base='o=uds'
host='ldap.unistra.fr'
filter="(&(objectClass=udsEmployee)(|(cn=*$@*)(givenName=*$@*)(sn=*$@*)(mail=*$@*)))"

status=`ldapsearch -h "$host" -w "$password" -D "$uid" -z $max -x -s one -l $timeout -b "$base" "$filter" 1.1 2>&1 | \\

grep -E '^(# )?(numResponses|numEntries|result|ldapsearch): '`
echo $status
count="`echo $status | grep numResponses: | sed -e 's/.*numResponses: \([0-9.+-]*\).*/\1/'`"
count="`expr ${count:-1} - 1`"
result="`echo $status | grep result: | sed -e 's/.*result: \([0-9.+-]*\) \([^ ]*\).*/\1/'`"
result="`expr ${result:--7} + 0`"
rmesg="`echo $status | grep ldapsearch:`"
#test -z "$rmesg" && \\

rmesg="rcode=$result `echo $status | grep result: | \\

sed -e 's/.*result: \([0-9.+-]*\) \([^#:]*\) [#]*[ ]*[A-Za-z]*[:]*.*/\2/'`"

if test "${result:-1}" -ne 0 -a "${result:-1}" -ne 4
then
  echo "ERROR: $rmesg"
  exit 2
fi

if test ${count:-0} -eq 0
then
  echo "Searching database ... $max entries ... $count matching."
  exit 1
fi


addresses=`ldapsearch -h "$host" -w "$password" -D "$uid" -S $sort -LLL -z $max -x -s one -l $timeout -b "$base" -a search "$filter" mail cn | \\
awk -F: '{printf $2 "£"} {if (NR%4==0) {printf "\n"}}' | \\
awk -F'£' '{printf $2 "\t" $3 "\n"}' | \\
awk -F"(" '{printf $1 "\t" substr($2, 0, length($2)-1) "\n"}i' `
echo "$addresses"
exit ${result:-0}