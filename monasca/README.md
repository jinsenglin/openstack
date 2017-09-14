# Metric Naming Convention

Reference:

* https://github.com/openstack/monasca-agent/blob/master/docs/MonascaMetrics.md#naming-conventions

# Metric Category

Reference:

* https://docs.google.com/spreadsheets/d/1TL1Y92ZFk7d2UV7CiRRaooU6LVn14Tz4V7u2yOYRUro/edit

Dimension Example

* category: Others
* target: Libvirt

# Spec of New Metric

cpu overcommit ratio

* metric name: overcommit_ratio.cpu
* value of category dimension: OpenStack
* value of target dimension: Nova
* value of hostname dimension: as usual

mem overcommit ratio

* metric name: overcommit_ratio.mem
* value of category dimension: OpenStack
* value of target dimension: Nova
* value of hostname dimension: as usual

# Spec of New Checks

check plugin name: overcommit_ratio

parameters:

* hypervisor_id

What is its interface? AgentCheck vs. ServicesCheck

How does it submit metric? gauge() vs. increment() vs. decrement() vs. histogram() vs. rate()

Does it need the corresponding detection plugin?

If yes, does it add a new detection plugin or modify an existing detection plugin? 

If adding a new detection plugin, what is its parent class? Plugin vs. ArgsPlugin vs. ServicePlugin

https://github.com/openstack/monasca-agent/blob/master/docs/Plugins.md#detection-plugins

# Spec for Enabling This New Checks

```
# For Compute Node 1
metric_check_frequency: 30
metric:
  - category: openstack
    targets:
    - nova:
      hypervisor_id: 1

# For Compute Node 2
metric_check_frequency: 30
metric:
  - category: openstack
    targets:
    - nova:
      hypervisor_id: 2

# For Compute Node 3
metric_check_frequency: 30
metric:
  - category: openstack
    targets:
    - nova:
      hypervisor_id: 3
```
