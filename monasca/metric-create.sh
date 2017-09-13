#!/bin/bash

set -e

monasca metric-create cpu1 123.40
monasca metric-create metric1 1234.56 --dimensions instance_id=123,service=ourservice
monasca metric-create metric1 2222.22 --dimensions instance_id=123,service=ourservice
monasca metric-create metric1 3333.33 --dimensions instance_id=222,service=ourservice
monasca metric-create metric1 4444.44 --dimensions instance_id=222 --value-meta rc=404
