# Setting resource overcommit ratios for the whole cluster

Key Steps:

* Use CoreFilter,RamFilter,DiskFilter in nova.conf for the default scheduler filter
* Specify cpu_allocation_ratio,ram_allocation_ratio,disk_allocation_ratio in nova.conf

Reference: 

* https://www.ibm.com/support/knowledgecenter/en/SS8MU9_2.2.0/Admin/tasks/settingresourceovercommitratios.html

# Setting resource overcommit ratios for a host aggregate

Key Steps:

* Use AggregateCoreFilter in nova.conf for the default scheduler filter
* Create a host aggregate
* Specify cpu_allocation_ratio for this host aggregate by `openstack aggregate set <this host aggregate> cpu_allocation_ratio=<N>`
* Add the host to this host aggregate

Reference:

* https://www.ibm.com/support/knowledgecenter/en/SS8MU9_2.2.0/Admin/tasks/settingresourceovercommitratios_individual.html
* http://maoxiaomeng.com/2016/02/27/openstack%E8%B6%85%E5%94%AE%E6%AF%94%E4%BE%8B%E4%B9%8Bvcpu/
