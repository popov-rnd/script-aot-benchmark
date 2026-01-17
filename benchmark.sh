#!/usr/bin/env bash

START=$(date +%s%3N)

$DEMO_COMMAND &
MY_PID=$!

# Wait for readiness
while [ "$(curl -s -o /dev/null -L -w '%{http_code}' http://localhost:8080/)" != "200" ]; do
  sleep 0.001
done

READY=$(date +%s%3N)

echo "=== After startup ==="
echo "Startup ms: $((READY - START))"
ps -p $MY_PID -o rss,cputime

echo "=== /proc/$PID/smaps_rollup ==="
cat /proc/"$PID"/smaps_rollup

# 100k requests
hey -n 100000 http://localhost:8080
echo "=== After 100k requests ==="
ps -p $MY_PID -o rss,cputime

# 1M requests
hey -n 1000000 http://localhost:8080
echo "=== After 1M requests ==="
ps -p $MY_PID -o rss,cputime

kill -9 $MY_PID
