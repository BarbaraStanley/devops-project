#!/usr/bin/env groovy
pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "us-east-1"
    }
    stages {
        // stage("Create an EKS Cluster") {
        //     steps {
        //         script {
        //             dir('terraform') {
        //                 sh "terraform init"
        //                 sh "terraform apply -auto-approve"
        //             }
        //         }
        //     }
        // }

        stage("Deploy app") {
            steps {
                script{
                    dir('miniapp/kubernetes') {
                        sh "kubectl create namespace id-gen"
                        sh "kubectl apply -f mongo-configmap.yaml"
                        sh "kubectl apply -f mongo-secret.yaml"
                        sh "kubectl apply -f mongodb.yaml"
                        sh "kubectl apply -f express.yml"
                        sh "kubectl apply -f idgen.yaml"
                    }
                }
            }
        }
        stage("Deploy sock app") {
            steps {
                script{
                    dir('microservices-demo/deploy/kubernetes') {
                        // sh "aws eks update-kubeconfig --name sock-shop"
                        sh "kubectl create namespace sock-shop"
                        sh "kubectl apply -f complete-demo.yaml"
                    }
                }
            }
        }
    }
}