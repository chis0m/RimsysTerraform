## Prerequisite
Create a hosted zone and update domain_name in variable.tf before running the script
### check Load balancer
kcl logs -f -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller