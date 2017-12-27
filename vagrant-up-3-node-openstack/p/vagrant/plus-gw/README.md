# Usage

```
vagrant up --provision-with download gw
vagrant up --provision-with download gw-client

vagrant ssh os-gw -c "sudo /vagrant/bootstrap-gw.sh configure"
vagrant ssh os-gw-client -c "sudo /vagrant/bootstrap-gw-client.sh configure"

vagrant ssh os-gw-client -c "sudo /vagrant/run-e2e-tests.sh"
```


