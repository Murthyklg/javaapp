pipeline {
    agent any

    environment {
        IMAGE_NAME = "murthy4797/javaapp"
        REGISTRY_CREDENTIALS = "github-webhook"
    }
   
    stages {

//checkout stage
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Murthyklg/javaapp.git'
            }
        }

//stage where commit id is trimmed till 7 characters and taken for reference
        stage('Get Commit SHA') {
            steps {
                script {
                    COMMIT_SHA = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()
                }
            }
        }
//build docker image with image id as build-build.id-commit.SHA which gives unique docker image everytime a build is triggered
        stage('Build Docker Image') {
            steps {
              //  script {
                //    IMAGE_TAG = "build-${BUILD_NUMBER}-${COMMIT_SHA}"
               //     sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
             //   }
                  script {
            IMAGE_TAG = "build-${BUILD_NUMBER}-${COMMIT_SHA}"
            echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
            dockerImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
        }
            }
        }
//login to dockerhub
        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${REGISTRY_CREDENTIALS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                }
            }
        }
//push docker image to dockerhub
        stage('Push Docker Image') {
            steps {
                script {
                   // sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                    echo "Pushing Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
            docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                dockerImage.push("${IMAGE_TAG}")   // push as build-<number>-<commit>  
                dockerImage.push('latest')         // also push as :latest 
                }
            }
        }

 stage('Deploy to Kubernetes (Canary)') {
    steps {
         withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
        sh 'kubectl get svc'
    }
        script {
           

            withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {

                sh 'kubectl get nodes'   // test connection

                sh "kubectl apply -f k8s/deployment.yaml"
                sh "kubectl apply -f k8s/service.yaml"
            }
        }
    }
}

    }

//success or failure message
    post {
        success {
            echo "Docker image pushed successfully: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
}
    
