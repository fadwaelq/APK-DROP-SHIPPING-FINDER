import requests
import json

url = "http://localhost:9000/api/qualitygates/project_status"
params = {"projectKey": "apk-dropshipping-finder"}
auth = ("sqa_820a5a11be41a897d12e3146a0231f31617dca97", "")

try:
    response = requests.get(url, params=params, auth=auth)
    if response.status_code == 200:
        status = response.json()
        print(json.dumps(status, indent=4))
    else:
        print(f"Error: {response.status_code}")
        print(response.text)
except Exception as e:
    print(f"Exception: {str(e)}")
