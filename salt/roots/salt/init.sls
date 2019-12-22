salt_disable:
  service.dead:
    - name: salt-minion
    - enable: False
