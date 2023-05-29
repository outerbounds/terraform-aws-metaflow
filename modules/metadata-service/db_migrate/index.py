import os, json
from urllib import request

def handler(event, context):
  response = {}
  status_endpoint = "{}/db_schema_status".format(os.environ.get('MD_LB_ADDRESS'))
  upgrade_endpoint = "{}/upgrade".format(os.environ.get('MD_LB_ADDRESS'))

  with request.urlopen(status_endpoint) as status:
    response['init-status'] = json.loads(status.read())

  upgrade_patch = request.Request(upgrade_endpoint, method='PATCH')
  with request.urlopen(upgrade_patch) as upgrade:
    response['upgrade-result'] = upgrade.read().decode()

  with request.urlopen(status_endpoint) as status:
    response['final-status'] = json.loads(status.read())

  print(response)
  return(response)
