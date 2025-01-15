#!/usr/bin/env bash
echo 'Starting agency looper for setting up database tables'
. substitute.sh

# Load in each agency & loop
for filename in /usr/local/transitclock/agencies/*.env; do
  [ -e "$filename" ] || continue
  . "${filename}"

  AGENCYID="${ID}" . create_tables.sh &
done
wait

echo 'Finished agency looper for setting up database tables'
