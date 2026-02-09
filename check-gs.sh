group=group_here
ns=namespace_here
users=$(oc get group $group -o jsonpath='{.users[*]}' | wc -w)
echo "users: ${users}"
rolebindings=$(oc get rolebinding edit -n $ns -o jsonpath='{range .subjects[?(@.kind=="User")]}{.name}{"\n"}{end}' | wc -l)
echo "rolebindings: ${rolebindings}"

if [[ "$users" -eq "$rolebindings" ]]; then
  echo "OK: counts match ($users)"
else
  diff=$(( users - rolebindings ))
  absdiff=${diff#-}
  echo "MISMATCH: users=$users rolebindings=$rolebindings (difference=$absdiff)"
fi