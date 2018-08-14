compute node :: install ceilometer (Telemetry Data Collection service, for short Telemetry service)

https://docs.openstack.org/ceilometer/pike/install/install-compute.html

---

controller node :: install ceilometer + gnocchi (Telemetry Metric service)

https://docs.openstack.org/ceilometer/pike/install/install-base-ubuntu.html

Prerequisites

Before you install and configure the Telemetry service, you must configure a target to send metering data to. The recommended endpoint is Gnocchi.

Usage

```
# display_name -> resource_id
openstack metric resource list --type instance -c id -c display_name

# resource_id -> metric_id
openstack metric resource show RESOURCE_ID

# metric_id -> measures
openstack metric measures show METRIC_ID

# details of a specific metric
openstack metric show METRIC_ID

# About points, granularity, timespan, archive policy
# See https://gnocchi.xyz/operating.html
```

---

next step :: install aodh (Telemetry Alarming service)

https://docs.openstack.org/aodh/pike/install/install-ubuntu.html

Usage

```
# create alarm (threshold rule alarm)
aodh alarm create --name ALARM-NAME --type gnocchi_resources_threshold --description 'ALARM-NAME' --metric cpu_util --threshold 1.0 --comparison-operator gt --aggregation-method mean --granularity 300 --evaluation-periods 1 --alarm-action 'log://' --resource-id RESOURCE_ID --resource-type instance

# details of an specific alarm
openstack alarm show ALARM_ID

# About threshold, comparison-operator, aggregation-method, granularity, evaluation-periods
# See https://docs.openstack.org/aodh/pike/admin/telemetry-alarms.html
# * The alarm granularity must match the granularities of the metric configured in Gnocchi.
# * As of Ocata, the threshold rule alarm is deprecated since Ceilometer’s native storage API is deprecated.
# * Combination rule alarms are deprecated as of Newton for composite alarms. Combination alarm functionality is removed in Pike.
# * -> Composite rule alarms are recommended.
```

---
