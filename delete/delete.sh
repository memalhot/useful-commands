pattern="^{adleo}"
for proj in $(oc get projects -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep "$pattern"); do
    echo "deleting resources"
    oc -n "$proj" delete pod,deployment,deploymentconfig,pvc,route,service,build,buildconfig,statefulset,replicaset,replicationcontroller,job,cronjob,imagestream,revision,configuration,notebook --all --as system:admin --ignore-not-found --wait=true || true
done