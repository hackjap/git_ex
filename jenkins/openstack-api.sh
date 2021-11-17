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
                    sh "mvn -P dev -f ./OpenStackApi/pom.xml clean package"
                    sh "ls -al ./OpenStackApi/target"
                    sh "pwd"
                }
            }
        }

        stage('Build Docker Image'){
            steps {
                container('docker'){
                    sh 'docker --version'
                    sh 'docker build -t harbor.okestro.cld/develop/openstack-api:latest ./OpenStackApi'
                    sh 'docker images'
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                container('docker'){
                    sh 'docker login harbor.okestro.cld -u admin -p okestro2018'
                    sh 'docker push harbor.okestro.cld/develop/openstack-api:latest'
                }
            }
        }

    }
}