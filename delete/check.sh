pattern="^{class-name}"
for proj in $(oc get projects -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep "$pattern"); do
    echo "checking for resources on $proj"
    oc project $proj
    oc get all --as system:admin
done