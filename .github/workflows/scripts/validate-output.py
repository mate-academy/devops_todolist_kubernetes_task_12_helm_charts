import re

file_path = "output.log"

try:
    with open(file_path, 'r') as file:
        log_data = file.read()
except FileNotFoundError:
    print("File Not Found!")
    log_data = ""

def check_pods(namespace, pod_prefix, required_count, status="Running"):
    pattern = rf"{namespace}\s+pod/{pod_prefix}[^\s]*\s+\d+/\d+\s+{status}"
    matches = re.findall(pattern, log_data)
    return len(matches) >= required_count

def check_resource(namespace, resource, resource_name):
    pattern = rf"{namespace}\s+{resource}/{resource_name}"
    return re.search(pattern, log_data) is not None

mysql_pods_ok = check_pods("mysql", "mysql-", 2)
todoapp_pods_ok = check_pods("todoapp", "todoapp", 2)
todoapp_hpa_ok = check_resource("todoapp", "horizontalpodautoscaler.autoscaling", "todoapp")
todoapp_ingress_ok = check_resource("todoapp", "ingress.networking.k8s.io", "todoapp-ingress")

print(f"mysql pods running: {mysql_pods_ok}")
print(f"todoapp pods running: {todoapp_pods_ok}")
print(f"todoapp horizontalpodautoscaler exists: {todoapp_hpa_ok}")
print(f"todoapp ingress exists: {todoapp_ingress_ok}")

if mysql_pods_ok and todoapp_ingress_ok and todoapp_pods_ok and todoapp_hpa_ok:
    print("All resources are found and are in a Running state.")
else:
    print("Not all required resources found or they are not in a Running state.")
