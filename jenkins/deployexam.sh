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
    image: jimador/docker-jdk-8-maven-node
    command:
    - cat
    tty: true
  - name: docker
    image: docker
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
                git branch: "dev",
                credentialsId: 'cicid-test',
                url: "https://gyujinan@bitbucket.org/okestrolab/cloud-platform-lab-setting.git"
                sh 'ls -al'
                sh 'pwd'
            }
        }
    
        
        stage('Deployment') {
            steps {
                sh 'ls -al'
                sh 'pwd'
                kubernetesDeploy(
                    configs: "dev-cmp/deploy-cmp/admin-app-deploy.yaml", 
                    kubeconfigId: "spjang-k8s", 
                )
            }
        }
    }
}