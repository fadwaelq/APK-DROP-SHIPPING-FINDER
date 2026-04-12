import requests
import json

url = "http://localhost:9000/api/issues/search"
params = {
    "componentKeys": "apk-dropshipping-finder",
    "resolved": "false",
    "facets": "types",
    "ps": 10
}
auth = ("sqa_820a5a11be41a897d12e3146a0231f31617dca97", "")

try:
    response = requests.get(url, params=params, auth=auth)
    if response.status_code == 200:
        data = response.json()
        issues = data.get("issues", [])
        for issue in issues:
            print(f"- [{issue.get('type')}] {issue.get('message')} ({issue.get('component')}:{issue.get('line')})")
    else:
        print(f"Error: {response.status_code}")
except Exception as e:
    print(f"Exception: {str(e)}")
