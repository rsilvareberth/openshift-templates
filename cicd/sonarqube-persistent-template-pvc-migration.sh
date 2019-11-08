#oc project default

### Confirm old PVC name and volume name (in this case registry and registry-storage)
# oc get pvc
# oc set volume dc sonarqube
# oc set volume dc sonardb

### Make sure to stop docker-registry and no write during migration
oc scale dc sonardb --replicas=0
oc scale dc sonarqube --replicas=0

### Spawn no-op container for the storage maintenance
oc run sleep --image=registry.access.redhat.com/rhel7/rhel-tools -- tail -f /dev/null

### Mount old PVC to that container
oc set volume dc/sleep --add -t pvc --name=sonardb --claim-name=sonardb --mount-path=/old-sonardb
oc set volume dc/sleep --add -t pvc --name=sonarqube-data --claim-name=sonarqube-data --mount-path=/old-sonarqube-data
oc set volume dc/sleep --add -t pvc --name=sonarqube-conf --claim-name=sonarqube-conf --mount-path=/old-sonarqube-conf
oc set volume dc/sleep --add -t pvc --name=sonarqube-extensions --claim-name=sonarqube-extensions --mount-path=/old-sonarqube-extensions
oc set volume dc/sleep --add -t pvc --name=sonarqube-logs --claim-name=sonarqube-logs  --mount-path=/old-sonarqube-logs
oc set volume dc/sleep --add -t pvc --name=sonarqube-temp --claim-name=sonarqube-temp --mount-path=/old-sonarqube-temp

### Create and mount new PV/PVC to that container.
### If you don't enable dynamic provisioning you need to create PV manually prior to this step
oc set volume dc/sleep --add -t pvc --name=new-sonardb --claim-name=sonardb-pvc --mount-path=/var/lib/pgsql/data --claim-mode=ReadWriteOnce --claim-size=1Gi
oc set volume dc/sleep --add -t pvc --name=new-sonarqube-data --claim-name=sonarqube-data --mount-path=/opt/sonarqube/data --claim-mode=ReadWriteOnce --claim-size=2Gi
oc set volume dc/sleep --add -t pvc --name=new-sonarqube-conf --claim-name=sonarqube-conf --mount-path=/opt/sonarqube/conf --claim-mode=ReadWriteOnce --claim-size=1Gi
oc set volume dc/sleep --add -t pvc --name=new-sonarqube-extensions --claim-name=sonarqube-extensions --mount-path=/opt/sonarqube/extensions --claim-mode=ReadWriteOnce --claim-size=1Gi
oc set volume dc/sleep --add -t pvc --name=new-sonarqube-logs --claim-name=sonarqube-logs --mount-path=/opt/sonarqube/logs --claim-mode=ReadWriteOnce --claim-size=1Gi
oc set volume dc/sleep --add -t pvc --name=new-sonarqube-temp --claim-name=sonarqube-temp --mount-path=/opt/sonarqube/temp --claim-mode=ReadWriteOnce --claim-size=1Gi

### rsh into the container
oc rsh sleep-X-XXXXX

### Migrate data to the new storage
#rsync -avxHAX --progress /old-registry/* /new-registry
# 1423212k   9052308  14% /old-sonarqube

#
start=$SECONDS; echo "** STARTING COPY "; cp -p -R  /old-sonardb/* /var/lib/pgsql/data; end=$SECONDS; echo " COPY FINISHED IN $((end - start)) SECONDS **";
start=$SECONDS; echo "** STARTING COPY "; cp -p -R  /old-sonarqube-data/* /opt/sonarqube/data/; end=$SECONDS; echo " COPY FINISHED IN $((end - start)) SECONDS **";
start=$SECONDS; echo "** STARTING COPY "; cp -p -R  /old-sonarqube-conf/* /opt/sonarqube/conf/; end=$SECONDS; echo " COPY FINISHED IN $((end - start)) SECONDS **";
start=$SECONDS; echo "** STARTING COPY "; cp -p -R  /old-sonarqube-conf/* /opt/sonarqube/extensions/; end=$SECONDS; echo " COPY FINISHED IN $((end - start)) SECONDS **";


### The last step, you need to switch to the new storage volume in docker-registry:
oc set volume dc/sonarqube --remove --name=sonar-data
oc set volume dc/sonarqube --add -t pvc --name=sonarqube-storage --claim-name=sonarqube-pvc --mount-path=/opt/sonarqube/data

### Restart docker-registry
oc scale dc sonarqube --replicas=1

### Remove maintenance pod
oc delete dc sleep

#Delete old sonarqube
VAR_OCP_PROJECT_CICD='cotec-cicd-tools'
# export VAR_OCP_PROJECT_CICD=cotec-cicd-tools



