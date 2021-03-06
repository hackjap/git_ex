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
        stage('Clone repository') {
            steps {
                git branch: "feature/develop",
                credentialsId: 'cicid-test',
                url: 'https://gyujinan@bitbucket.org/okestrolab/flowerduet-test.git'
                sh 'ls -al'
                sh 'pwd'
            }
        }
        
        stage('Maven Build') {
            steps {
                container('maven-jdk-node'){
                    sh 'mvn -v'
                    sh "mvn -P dev -f ./UserApi/pom.xml clean package"
                    sh "ls -al ./UserApi/target"
                    sh "pwd"
                }
            }
        }

        stage('Build Docker Image'){
            steps {
                container('docker'){
                    sh 'docker --version'
                    sh 'docker build -t harbor.okestro.cld/develop/user-api:latest ./UserApi'
                    sh 'docker images'
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                container('docker'){
                    sh 'docker login harbor.okestro.cld -u admin -p okestro2018'
                    sh 'docker push harbor.okestro.cld/develop/user-api:latest'
                }
            }
        }
        
           stages {
        
        stage("deployment") {

            steps {

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
      app: userapi-app
      version: blue
  template:
    metadata:
      name: userapi-pod
      labels:
        app: userapi-app
        version: blue
    spec:
      containers:
        - name: userapi-container
          image: harbor.okestro.cld/okestro/user-api
          imagePullPolicy: Always
          ports:
            - containerPort: 18081
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: deploy

            - name: SPRING_CLOUD_VAULT_HOST
              value: 100.0.0.189

            - name: SPRING_CLOUD_VAULT_TOKEN
              value: s.0D8xFysWozVxuownT0RZlRdH

            - name: SPRING_CLOUD_VAULT_KV_APPLICATION-NAME
              value: prd/portal/user

      imagePullSecrets:
        - name: harborcred''' > deploy.yaml"""

                        sh "cat deploy.yaml"

                        kubernetesDeploy(configs: "deploy.yaml", kubeconfigId: "spjang-k8s")

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
                    }//script
                }
            }
           }


        # stage('Deployment') {
        #     steps {
        #         sh 'ls -al'
        #         sh 'pwd'
        #         kubernetesDeploy(
        #             configs: "UserApi/deployment-user-api.yaml", 
        #             kubeconfigId: "spjang-k8s", 
        #         )
        #     }
        # }

    }

      post {

        always {

            cleanWs()
        }
    }
}