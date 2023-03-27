#!/usr/bin/env groovy
pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "us-east-1"
        NAMESPACE = "id-gen"
        NAMESPACE1 = "sock-shop"
        NAMESPACE2 = "monitoring"
    }
    stages {
        // stage("Configure aws cli") {
        //     steps {
        //         script {
        //             dir('.') {
        //                 sh "aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" && aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" && aws configure set region "$AWS_DEFAULT_REGION" && aws configure set output "text""
        //             }
        //         }
        //     }
        // }

        stage("Create an EKS Cluster") {
            steps {
                script {
                    dir('terraform') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }

        stage("Deploy app") {
            steps {
                script{
                    dir('miniapp/kubernetes') {
                        sh "aws eks update-kubeconfig --name devops-cluster --region us-east-1"
                        sh "kubectl get namespace $NAMESPACE || kubectl create namespace $NAMESPACE"
                        sh "kubectl apply -f mongo-configmap.yaml"
                        sh "kubectl apply -f mongo-secret.yaml"
                        sh "kubectl apply -f mongodb.yaml"
                        sh "kubectl apply -f idgen.yaml"
                    }
                }
            }
        }
        stage("Deploy sock monitoring") {
            steps {
                script{
                    dir('microservices-demo/') {
                        sh "kubectl create -f ./deploy/kubernetes/manifests-monitoring"
                    }
                }
            }
        }
        stage("Deploy sock app") {
            steps {
                script{
                    dir('microservices-demo/deploy/kubernetes') {
                        sh "kubectl get namespace $NAMESPACE1 || kubectl create namespace $NAMESPACE1"
                        sh "kubectl get namespace $NAMESPACE2 || kubectl create namespace $NAMESPACE2"
                        sh "kubectl apply -f complete-demo.yaml"
                        sh "kubectl apply -f ingresser.yaml"
                    }
                }
            }
        }
    }
}