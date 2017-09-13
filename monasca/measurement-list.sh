#!/bin/bash

set -e

monasca measurement-list cpu1 2017-07-01T00:00:00Z
monasca measurement-list --dimensions instance_id=123,service=ourservice metric1 2017-07-01T00:00:00Z
monasca measurement-list --dimensions instance_id=123 --merge_metrics metric1 2017-07-01T00:00:00Z
monasca measurement-list --dimensions instance_id=222,service=ourservice metric1 2017-07-01T00:00:00Z
monasca measurement-list --dimensions instance_id=222 --merge_metrics metric1 2017-07-01T00:00:00Z
monasca measurement-list --merge_metrics metric1 2017-07-01T00:00:00Z
