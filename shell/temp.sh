#!/bin/sh

arr=(AdminApi AdminApp DashboardApi DashboardApp UserApi UserApp OpenStackApi OpenStackApp  )


version=dev

echo ---mvn build---

for i in $arr
do
	mvn -P $version -f ./$i/pom.xml clean package
done

echo ---mk img---

app="adminapp adminapi userapp userapi openstackapp openstackapi dashboardapp dashboardapi service-catalog-engine cloud-service-broker"\
repo="harbor.dreamcloud.co.kr/okestro


#docker build --tag $repo/adminapi:latest AdminApi/
#docker build --tag $repo/adminapp:latest AdminApp/
#docker build --tag $repo/cloud-service-broker:latest CloudServiceBroker/
#docker build --tag $repo/dashboard-api:latest DashboardApi/
#docker build --tag $repo/dashboard-app:latest DashboardApp/
#docker build --tag $repo/gateapi:latest GateApi/
#docker build --tag $repo/gateapp:latest GateApp/
#docker build --tag $repo/openstackapi:latest OpenStackApi/
#docker build --tag $repo/openstackapp:latest OpenStackApp/
#docker build --tag $repo/service-catalog-engine:latest ServiceCatalogEngine/
#docker build --tag $repo/userapi:latest UserApi/
docker build --tag  $repo/userapp:latest UserApp/

