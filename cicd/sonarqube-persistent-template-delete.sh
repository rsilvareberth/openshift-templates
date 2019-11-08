VAR_OCP_PROJECT_CICD='<project_name>'
# export VAR_OCP_PROJECT_CICD=cotec-cicd-tools

oc delete is sonarqube -n $VAR_OCP_PROJECT_CICD
oc delete dc sonarqube -n $VAR_OCP_PROJECT_CICD
oc delete dc sonardb -n $VAR_OCP_PROJECT_CICD
oc delete svc sonarqube -n $VAR_OCP_PROJECT_CICD
oc delete svc sonardb -n $VAR_OCP_PROJECT_CICD
oc delete routes sonarqube -n $VAR_OCP_PROJECT_CICD
oc delete secret sonardb  -n $VAR_OCP_PROJECT_CICD
oc delete secret sonar-ldap-bind-dn -n $VAR_OCP_PROJECT_CICD
oc delete pvc sonardb  -n $VAR_OCP_PROJECT_CICD
oc delete pvc sonarqube-conf  -n $VAR_OCP_PROJECT_CICD
oc delete pvc sonarqube-data  -n $VAR_OCP_PROJECT_CICD
oc delete pvc sonarqube-extensions  -n $VAR_OCP_PROJECT_CICD
oc delete pvc sonarqube-logs  -n $VAR_OCP_PROJECT_CICD
oc delete pvc sonarqube-temp  -n $VAR_OCP_PROJECT_CICD
# oc delete pv [pv-id] -n $VAR_OCP_PROJECT_CICD