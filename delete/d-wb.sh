pattern="^{class-name}"
for proj in $(oc get projects -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep "$pattern"); do
    echo "deleting project $proj"
    oc delete project "$proj" --as system:admin || true
done