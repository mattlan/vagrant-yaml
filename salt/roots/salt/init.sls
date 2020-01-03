{%- if salt['config.get']('file_client') == 'local' %}

salt_minion:
  service.dead:
    - name: salt-minion
    - enable: False

{%- else %}

salt_minion:
  service.running:
    - name: salt-minion
    - enable: True

{%- endif %}
