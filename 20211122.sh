pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: pod
spec:
  containers:
  - name: maven-jdk-node
    image: harbor.okestro.cld/okestro/docker-jdk-8-maven-node
    command:
    - cat
    tty: true
  - name: docker
    image: harbor.okestro.cld/okestro/docker  
    volumeMounts:
    - name: dockersock
      mountPath: "/var/run/docker.sock"
    command:
    - cat
    tty: true
  volumes:
  - name: dockersock
    hostPath:
      path: /var/run/docker.sock
  - name: hosts
    hostPath:
      path: /etc/hosts
"""
        }
    }

    stages {

         stage('Deployment') {
            steps {
                //sh 'ls -al'
                //sh 'pwd'

            //yaml 
         script{

                sh """echo '''---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-api
  namespace: portal
spec:
  replicas: 1
  selector:
    matchLabels:
      app: userapi-pods-label
  template:
    metadata:
      name: userapi-pod
      labels:
        app: userapi-pods-label
    spec:
      containers:
      - name: userapi-container
        env:
          - name: SPRING_CLOUD_VAULT_HOST
            valueFrom: 
              configMapKeyRef: 
                name: cm-user-api
                key: spring_cloud_vault_host
          - name: SPRING_CLOUD_VAULT_TOKEN
            valueFrom: 
              configMapKeyRef: 
                name: cm-user-api
                key: spring_cloud_vault_token
          - name: LOGGING_LEVEL_CLOUDPLATFORM
            valueFrom: 
              configMapKeyRef: 
                name: cm-user-api
                key: logging_level_cloudplatform
          - name: LOGGING_LEVEL_ORG_SPRINGFRAMWORK
            valueFrom: 
              configMapKeyRef: 
                name: cm-user-api
                key: logging_level_org_springframework
          - name: LOGGING_LEVEL_ORG_SPRINGFRAMWORK_WEB
            valueFrom: 
              configMapKeyRef: 
                name: cm-user-api
                key: logging_level_org_springframework_web
          - name: LOGGING_LEVEL_ORG_HIBERNATE_SQL
            valueFrom: 
              configMapKeyRef: 
                name: cm-user-api
                key: logging_level_org_hibernate_sql
          - name: LOGGING_LEVEL_ORG_HIBERNATE_TYPE
            valueFrom: 
              configMapKeyRef: 
                name: cm-user-api
                key: logging_level_org_hibernate_type
        image: harbor.okestro.cld/okestro/userapi:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 18081
        resources:
          limits:
            memory: "1000Mi"
            cpu: "1000m"
          requests:
            memory: "1000Mi"
            cpu: "1000m"
      imagePullSecrets:
      - name: harborcred ''' > deploy.yaml"""

            //script 
            sh "cat deploy.yaml"

            // k8s 
                kubernetesDeploy(
                    configs: "UserApi/deployment-user-api.yaml", 
                    kubeconfigId: "spjang-k8s", 
                )

            def cloud = [:]
                cloud.name = "master"
                cloud.host = "192.168.65.33"
                cloud.port = 22
                cloud.user = "ubuntu"
                cloud.password = "okestro2018!"
                cloud.allowAnyHosts = true

                try {

                    sshCommand remote: cloud, command: """sudo kubectl rollout restart deploy user-api -n portal"""

                } catch(e) {

                    currentBuild.result = "SUCCESS"
                }

            }// script 
        }
        
    }
}




        # stage('Maven Build') {
        #     steps {
        #         container('maven-jdk-node'){
        #             sh 'mvn -v'
        #             sh "mvn -P dev -f ./GateApi/pom.xml clean package"
        #             sh "ls -al ./GateApi/target"
        #             sh "pwd"
        #         }
        #     }
        # }

        # stage('Build Docker Image'){
        #     steps {
        #         container('docker'){
        #             sh 'docker --version'
        #             sh 'docker build -t harbor.okestro.cld/develop/gate-api:latest ./GateApi'
        #             sh 'docker images'
        #         }
        #     }
        # }
        
        # stage('Push Docker Image') {
        #     steps {
        #         container('docker'){
        #             sh 'docker login harbor.okestro.cld -u admin -p okestro2018'
        #             sh 'docker push harbor.okestro.cld/develop/gate-api:latest'
        #         }
        #     }
        # }