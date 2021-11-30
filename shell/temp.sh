appPath=( DashboardApp UserApi UserApp )
appName=( dashboard-app  user-api user-app )

echo --- (docker build)amd64 기반의 도커 이미지를 생성합니다... ---

for i in {0..2}
do
 docker pull harbor.okestro.cld/dream-markone/${appName[$i]}:1130 
done


echo --- docker save...  이미지를 tar파일로 저장합니다... ---
mkdir amd64_images && cd amd64_images
for i in {0..8}
do
 echo ${appName[$i]} 생성중 ...
 docker save -o ${appName[$i]}.tar ${appName}:amd64
done