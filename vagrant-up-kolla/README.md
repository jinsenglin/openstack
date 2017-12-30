# Status

```
TASK [common : Pulling common images] ******************************************
failed: [localhost] (item={'key': u'cron', 'value': {u'environment': {u'DUMMY_ENVIRONMENT': u'kolla_useless_env'}, u'image': u'kolla/centos-binary-cron:5.0.1', u'volumes': [u'/etc/kolla//cron/:/var/lib/kolla/config_files/:ro', u'/etc/localtime:/etc/localtime:ro', u'kolla_logs:/var/log/kolla/'], u'container_name': u'cron'}}) => {"failed": true, "item": {"key": "cron", "value": {"container_name": "cron", "environment": {"DUMMY_ENVIRONMENT": "kolla_useless_env"}, "image": "kolla/centos-binary-cron:5.0.1", "volumes": ["/etc/kolla//cron/:/var/lib/kolla/config_files/:ro", "/etc/localtime:/etc/localtime:ro", "kolla_logs:/var/log/kolla/"]}}, "msg": "Unknown error message: Tag 5.0.1 not found in repository docker.io/kolla/centos-binary-cron"}

failed: [localhost] (item={'key': u'fluentd', 'value': {u'environment': {u'KOLLA_CONFIG_STRATEGY': u'COPY_ALWAYS'}, u'image': u'kolla/centos-binary-fluentd:5.0.1', u'volumes': [u'/etc/kolla//fluentd/:/var/lib/kolla/config_files/:ro', u'/etc/localtime:/etc/localtime:ro', u'kolla_logs:/var/log/kolla/'], u'container_name': u'fluentd'}}) => {"changed": true, "failed": true, "item": {"key": "fluentd", "value": {"container_name": "fluentd", "environment": {"KOLLA_CONFIG_STRATEGY": "COPY_ALWAYS"}, "image": "kolla/centos-binary-fluentd:5.0.1", "volumes": ["/etc/kolla//fluentd/:/var/lib/kolla/config_files/:ro", "/etc/localtime:/etc/localtime:ro", "kolla_logs:/var/log/kolla/"]}}, "msg": "'Traceback (most recent call last):\\n  File \"/tmp/ansible_wsCRGY/ansible_module_kolla_docker.py\", line 799, in main\\n    result = bool(getattr(dw, module.params.get(\\'action\\'))())\\n  File \"/tmp/ansible_wsCRGY/ansible_module_kolla_docker.py\", line 456, in pull_image\\n    repository=image, tag=tag, stream=True\\n  File \"/usr/local/lib/python2.7/dist-packages/docker/api/image.py\", line 345, in pull\\n    self._raise_for_status(response)\\n  File \"/usr/local/lib/python2.7/dist-packages/docker/api/client.py\", line 208, in _raise_for_status\\n    raise create_api_error_from_http_exception(e)\\n  File \"/usr/local/lib/python2.7/dist-packages/docker/errors.py\", line 30, in create_api_error_from_http_exception\\n    raise cls(e, response=response, explanation=explanation)\\nAPIError: 500 Server Error: Internal Server Error for url: http+docker://localunixsocket/v1.24/images/create?tag=5.0.1&fromImage=kolla%2Fcentos-binary-fluentd (\"Get https://registry-1.docker.io/v2/kolla/centos-binary-fluentd/manifests/5.0.1: Get https://auth.docker.io/token?scope=repository%3Akolla%2Fcentos-binary-fluentd%3Apull&service=registry.docker.io: net/http: request canceled (Client.Timeout exceeded while awaiting headers)\")\\n'"}
failed: [localhost] (item={'key': u'kolla-toolbox', 'value': {u'environment': {u'ANSIBLE_LIBRARY': u'/usr/share/ansible', u'ANSIBLE_NOCOLOR': u'1'}, u'image': u'kolla/centos-binary-kolla-toolbox:5.0.1', u'privileged': True, u'volumes': [u'/etc/kolla//kolla-toolbox/:/var/lib/kolla/config_files/:ro', u'/etc/localtime:/etc/localtime:ro', u'/dev/:/dev/', u'/run/:/run/:shared', u'kolla_logs:/var/log/kolla/'], u'container_name': u'kolla_toolbox'}}) => {"failed": true, "item": {"key": "kolla-toolbox", "value": {"container_name": "kolla_toolbox", "environment": {"ANSIBLE_LIBRARY": "/usr/share/ansible", "ANSIBLE_NOCOLOR": "1"}, "image": "kolla/centos-binary-kolla-toolbox:5.0.1", "privileged": true, "volumes": ["/etc/kolla//kolla-toolbox/:/var/lib/kolla/config_files/:ro", "/etc/localtime:/etc/localtime:ro", "/dev/:/dev/", "/run/:/run/:shared", "kolla_logs:/var/log/kolla/"]}}, "msg": "Unknown error message: Get https://registry-1.docker.io/v1/repositories/kolla/centos-binary-kolla-toolbox/tags/5.0.1: net/http: TLS handshake timeout"}
    to retry, use: --limit @/usr/local/share/kolla-ansible/ansible/site.retry

PLAY RECAP *********************************************************************
localhost                  : ok=4    changed=0    unreachable=0    failed=1

Command failed ansible-playbook -i /usr/local/share/kolla-ansible/ansible/inventory/all-in-one -e @/etc/kolla/globals.yml -e @/etc/kolla/passwords.yml -e CONFIG_DIR=/etc/kolla  -e action=pull /usr/local/share/kolla-ansible/ansible/site.yml
```

# Usage

```
vagrant up
```

REF https://qiita.com/radedance/items/ba656f69fad407097efc

REF https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html
