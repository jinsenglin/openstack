# Problem

To display overcommit ratio

# Approach

Method 1: No new metric, use frontend UI to apply the math expression on existing metric

Method 2: A new metric, use backend engine to apply the math expression on existing metric

Method 3: A new metric, use backend agent to generate new metric

# Metric Naming Convention

Reference:

* https://github.com/openstack/monasca-agent/blob/master/docs/MonascaMetrics.md#naming-conventions
* https://github.com/openstack/monasca-agent/blob/master/docs/Libvirt.md#aggregate-metrics

Example:

* nova.vm.cpu.total_allocated
* nova.vm.disk.total_allocated_gb
* nova.vm.mem.total_allocated_mb

Candidate:

* nova.vm.cpu.overcommit_ratio
* nova.vm.mem.overcommit_ratio

# Metric Category

Reference:

* https://docs.google.com/spreadsheets/d/1TL1Y92ZFk7d2UV7CiRRaooU6LVn14Tz4V7u2yOYRUro/edit

Dimension Example

* category: Others and target: Libvirt
* category: OpenStack and target: Nova

# Spec of New Metric

cpu overcommit ratio

* metric name: nova.vm.cpu.overcommit_ratio
* value of category dimension: Others
* value of target dimension: Libvirt
* value of hostname dimension

mem overcommit ratio

* metric name: nova.vm.mem.overcommit_ratio
* value of category dimension: Others
* value of target dimension: Libvirt
* value of hostname dimension

# Spec of New Checks

check plugin name: overcommit_ratio

parameters:

* hypervisor_id

Q1: What is its interface? AgentCheck vs. ServicesCheck

Q2: How does it submit metric? gauge() vs. increment() vs. decrement() vs. histogram() vs. rate()

Q3: Does it need the corresponding detection plugin?

Q4: If yes, does it add a new detection plugin or modify an existing detection plugin? 

Q5: If adding a new detection plugin, what is its parent class? Plugin vs. ArgsPlugin vs. ServicePlugin

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
