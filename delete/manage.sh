#!/bin/bash

set -e

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] PATTERN

Manage OpenShift namespaces/projects matching a pattern.

OPTIONS:
    -c, --check             Check and list all resources in matching projects
    -r, --delete-resources  Delete all resources within matching projects (keeps projects)
    -p, --delete-projects   Delete the entire projects matching pattern
    -h, --help              Show this help message

PATTERN:
    Regex pattern to match project names (e.g., "^adleo", "^{class-name}")

EXAMPLES:
    $(basename "$0") --check "^adleo"
    $(basename "$0") --delete-resources "^{class-name}"
    $(basename "$0") --delete-projects "^{class-name}"

EOF
    exit 1
}

check_resources() {
    local pattern="$1"
    echo "Checking resources in projects matching: $pattern"
    echo "================================================"

    for proj in $(oc get projects -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep "$pattern"); do
        echo ""
        echo "Checking for resources in $proj"
        echo "--------------------------------"
        oc project "$proj"
        oc get all --as system:admin
    done
}

delete_resources() {
    local pattern="$1"
    echo "Deleting resources in projects matching: $pattern"
    echo "=================================================="

    for proj in $(oc get projects -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep "$pattern"); do
        echo "Deleting resources in $proj"
        oc -n "$proj" delete pod,deployment,deploymentconfig,pvc,route,service,build,buildconfig,statefulset,replicaset,replicationcontroller,job,cronjob,imagestream,revision,configuration,notebook --all --as system:admin --ignore-not-found --wait=true || true
    done

    echo "Resource deletion complete"
}

delete_projects() {
    local pattern="$1"
    echo "Deleting projects matching: $pattern"
    echo "====================================="

    for proj in $(oc get projects -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep "$pattern"); do
        echo "Deleting project $proj"
        oc delete project "$proj" --as system:admin || true
    done

    echo "Project deletion complete"
}

# Parse command line arguments
ACTION=""
PATTERN=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--check)
            ACTION="check"
            shift
            ;;
        -r|--delete-resources)
            ACTION="delete-resources"
            shift
            ;;
        -p|--delete-projects)
            ACTION="delete-projects"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [[ -z "$PATTERN" ]]; then
                PATTERN="$1"
            else
                echo "Error: Unknown option or too many arguments: $1"
                usage
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [[ -z "$ACTION" ]]; then
    echo "Error: No action specified. Use -c, -r, or -p"
    usage
fi

if [[ -z "$PATTERN" ]]; then
    echo "Error: No pattern specified"
    usage
fi

# Execute the requested action
case $ACTION in
    check)
        check_resources "$PATTERN"
        ;;
    delete-resources)
        delete_resources "$PATTERN"
        ;;
    delete-projects)
        delete_projects "$PATTERN"
        ;;
esac
