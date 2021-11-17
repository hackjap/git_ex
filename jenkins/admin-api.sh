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
                    sh "mvn -P dev -f ./AdminApi/pom.xml clean package"
                    sh "ls -al ./AdminApi/target"
                    sh "pwd"
                }
            }
        }

        stage('Build Docker Image'){
            steps {
                container('docker'){
                    sh 'docker --version'
                    sh 'docker build -t harbor.okestro.cld/develop/admin-api:latest ./AdminApi'
                    sh 'docker images'
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                container('docker'){
                    sh 'docker login harbor.okestro.cld -u admin -p okestro2018'
                    sh 'docker push harbor.okestro.cld/develop/admin-api:latest'
                }
            }
        }

        stage("deployment") {

            steps {

                script{

                    sh """echo '''---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pipelineapi
  namespace: cicd
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pipelineapi-app
      version: blue
  template:
    metadata:
      name: pipelineapi-pod
      labels:
        app: pipelineapi-app
        version: blue
    spec:
      containers:
        - name: pipelineapi-container
          image: harbor.okestro.cld/okestro/pipelineapi
          imagePullPolicy: Always
          ports:
            - containerPort: 18081
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: deploy

            - name: SPRING_CLOUD_VAULT_HOST
              value: vault.dreamcloud.co.kr

            - name: SPRING_CLOUD_VAULT_TOKEN
              value: s.IEoYUCC0bGnQiJeSrfiIsXdQß

            - name: SPRING_CLOUD_VAULT_KV_APPLICATION-NAME
              value: prd/portal/devops_k8s

      imagePullSecrets:
        - name: harborcred''' > deploy.yaml"""

                        sh "cat deploy.yaml"

                        kubernetesDeploy(configs: "deploy.yaml", kubeconfigId: "spjang")

                        def cloud = [:]
                        cloud.name = "master"
                        cloud.host = "172.168.50.100"
                        cloud.port = 22
                        cloud.user = "ubuntu"
                        cloud.password = "cloud1234"
                        cloud.allowAnyHosts = true

                        try {

                            sshCommand remote: cloud, command: """sudo kubectl rollout restart deploy pipelineapi -n cicd"""

                        } catch(e) {

                            currentBuild.result = "SUCCESS"
                        }
                    }
                }
            }
        }
    }

    post {

        always {

            cleanWs()
        }

    }
}