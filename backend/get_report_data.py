import requests
import json
import os

url_status = "http://localhost:9000/api/qualitygates/project_status"
url_measures = "http://localhost:9000/api/measures/component"
project_key = "apk-dropshipping-finder"
auth = ("sqa_820a5a11be41a897d12e3146a0231f31617dca97", "")

params_status = {"projectKey": project_key}
params_measures = {
    "component": project_key,
    "metricKeys": "bugs,vulnerabilities,code_smells,coverage,duplicated_lines_density,security_hotspots"
}

report = {}

try:
    # 1. Quality Gate Status
    res_status = requests.get(url_status, params=params_status, auth=auth)
    if res_status.status_code == 200:
        report['status'] = res_status.json()['projectStatus']
    
    # 2. Key Measures
    res_measures = requests.get(url_measures, params=params_measures, auth=auth)
    if res_measures.status_code == 200:
        report['measures'] = res_measures.json()['component']['measures']

    print(json.dumps(report, indent=4))
except Exception as e:
    print(f"Error: {str(e)}")
