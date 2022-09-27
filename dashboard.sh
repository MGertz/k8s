
wget https://raw.githubusercontent.com/MGertz/k8s/main/dashboard.admn-user-role.yml
wget https://raw.githubusercontent.com/MGertz/k8s/main/dashboard.admn-user.yml
wget https://raw.githubusercontent.com/MGertz/k8s/main/dashboard.nodeport_patch.yaml
wget https://raw.githubusercontent.com/MGertz/k8s/main/dashboard.recommended.yaml


# Apply configuration for Dashboard
kubectl apply -f dashboard.recommended.yaml

# Patch service to listen to nodeport
kubectl --namespace kubernetes-dashboard patch svc kubernetes-dashboard -p '{"spec": {"type": "NodePort"}}'

# Expose the nodeport on all nodes
kubectl -n kubernetes-dashboard patch svc kubernetes-dashboard --patch "$(cat dashboard.nodeport_patch.yaml)"

# Apply admin user
kubectl create -f dashboard.admin-user.yml 

# Apply User Role
kubectl create -f dashboard.admin-user-role.yml










