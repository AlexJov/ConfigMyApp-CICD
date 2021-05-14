#!/bin/bash

# 1. INPUT PARAMETERS
_controller_url="configmyappdemo-****.appd-cx.com:8090/controller"   # hostname + /controller
_user_credentials="userHere@customer1:passHere" # ${username}@${account}:${password}

_application_name=test-me #Jenkins_API_Demo #Producktion
_proxy_details=

_health_rules_overwrite=true
_include_sim=true

function func_get_application_id() {
    local _controller_url=${1} # hostname + /controller
    local _user_credentials=${2} # ${username}:${password}

    local _application_name=${3}
    local _proxy_details=${4} 

    # Get all applications
    allApplications=$(curl -s --user ${_user_credentials} ${_controller_url}/rest/applications?output=JSON ${_proxy_details})

    # Select by name
    applicationObject=$(jq --arg appName "$_application_name" '.[] | select(.name == $appName)' <<<$allApplications)

    if [ "$applicationObject" = "" ]; then
        exit 1
    fi

    appId=$(jq '.id' <<<$applicationObject)

    echo "${appId}"
}

# get app id
echo "Getting app id..."
appId=$(func_get_application_id ${_controller_url} ${_user_credentials} ${_application_name} ${_proxy_details} )
echo "Application id is: ${appId}"

# get all current health rules for application
allHealthRules=$(curl -s --user ${_user_credentials} ${_controller_url}/alerting/rest/v1/applications/${appId}/health-rules ${_proxy_details})

destfile="./exported/all_${_application_name}_health_rules.json"
touch ${destfile}
echo "Save HRs to file..."
echo "$allHealthRules" > "$destfile"

# export specific rule
hrid=467 #todo, replace with ID from previous request... or loop trough ids

destfile="./exported/spec_${_application_name}_health_rules.json"
specHR=$(curl -s --user ${_user_credentials} ${_controller_url}/alerting/rest/v1/applications/${appId}/health-rules/${hrid} ${_proxy_details})
echo "Save HR to file..."
echo "$specHR" > "$destfile"