#!/bin/bash

set -e

PERIOD=2592000 # 24*60*60*30

for stat in AVG MIN MAX COUNT SUM
do
    monasca metric-statistics --period $PERIOD cpu1 $stat 2017-07-01T00:00:00Z
    monasca metric-statistics --dimensions instance_id=123,service=ourservice --period $PERIOD metric1 $stat 2017-07-01T00:00:00Z
    monasca metric-statistics --dimensions instance_id=123 --merge_metrics --period $PERIOD metric1 $stat 2017-07-01T00:00:00Z
    monasca metric-statistics --dimensions instance_id=222,service=ourservice --period $PERIOD metric1 $stat 2017-07-01T00:00:00Z
    monasca metric-statistics --dimensions instance_id=222 --merge_metrics --period $PERIOD metric1 $stat 2017-07-01T00:00:00Z
    monasca metric-statistics --merge_metrics --period $PERIOD metric1 $stat 2017-07-01T00:00:00Z
done
