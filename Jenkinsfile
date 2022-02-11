pipeline{
    environment{
        IMAGE_NAME = "img-webapp"
        IMAGE_TAG = "${BUILD_TAG}"
        USERNAME = "26021973"
        CONTAINTER_NAME = "webapp"
        STAGING = "52.21.170.76"
        PRODUCTION = "18.205.185.188"
    }
    agent any
    
    stages {
        stage ('Build du conteneur') {
            agent {
                label 'test'
            }
            steps {
                script {
                    sh 'docker build -t ${IMAGE_NAME} .'
                }
            }
        }
        stage ('Verification image') {
            agent {
                label 'test'
            }           
            steps {
                script {
                    sh '''
                        docker stop ${CONTAINTER_NAME} || true
                        docker rm ${CONTAINTER_NAME} || true
                        docker run -d -p 8081:80 --name ${CONTAINTER_NAME} ${IMAGE_NAME}
                        sleep 5
                        curl http://localhost:8081 
                    '''
                }
            }   
        }
        stage ('Push image') {
            agent {
                label 'test'
            }
            environment {
                PASSWORD=credentials('dockerhub_password')
            }
            steps {
                script {
                    sh '''
                        docker stop ${CONTAINTER_NAME} || true
                        docker rm ${CONTAINTER_NAME} || true
                        docker tag ${IMAGE_NAME} ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker login -u ${USERNAME} -p ${PASSWORD}
                        docker push ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker rmi ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    '''

                }
            }
        }
        stage ('Deploy staging') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: "credential_ec2", keyFileVariable: 'keyfile', usernameVariable: 'sshuser')]) {
                    script {
                        sh '''
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${STAGING} -C docker stop ${CONTAINTER_NAME} || true
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${STAGING} -C docker rm ${CONTAINTER_NAME} || true                      
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${PRODUCTION} -C docker image prune -af || true                       
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${STAGING} -C docker run -d -p 80:80 --name ${CONTAINTER_NAME} ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${STAGING} -C sleep 5
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${STAGING} -C curl http://localhost:80
                        '''
                    }
                }
            }
        }

 /*       stage ('Deploy prod') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: "credential_ec2", keyFileVariable: 'keyfile', usernameVariable: 'sshuser')]) {
                    script {
                        timeout(time: 15, unit: "MINUTES") {
                            input message: 'Do you want to approve the deploy in production?', ok: 'Yes'
                        }
                        sh '''
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${PRODUCTION} -C docker stop ${CONTAINTER_NAME} || true
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${PRODUCTION} -C docker rm ${CONTAINTER_NAME} || true                       
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${PRODUCTION} -C docker image prune -af || true                       
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${PRODUCTION} -C docker run -d -p 80:80 --name ${CONTAINTER_NAME} ${USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${STAGING} -C sleep 5
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} -y ${sshuser}@${PRODUCTION} -C curl http://localhost:80
                        '''
                    }
                }
            }
        }
    */
        stage('Deploy prod') {
            agent {
                docker {
                    image('alpine')
                    args ' -u root'
                }
            }
            when{
                expression{ GIT_BRANCH == 'origin/master'}
            }
            steps{
                withCredentials([sshUserPrivateKey(credentialsId: "credential_ec2", keyFileVariable: 'keyfile', usernameVariable: 'sshuser')]) {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        script{
                            timeout(time: 15, unit: "MINUTES") {
                                input message: 'Do you want to approve the deploy in production?', ok: 'Yes'
                            }						
                            sh'''
                                apk update
                                which ssh-agent || ( apk add openssh-client )
                                eval $(ssh-agent -s)
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${sshuser}@${PRODUCTION} docker stop $CONTAINER_NAME || true
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${sshuser}@${PRODUCTION} docker rm $CONTAINER_NAME || true
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${sshuser}@${PRODUCTION} docker rmi $USERNAME/$IMAGE_NAME:$IMAGE_TAG || true
                                ssh -o StrictHostKeyChecking=no -i ${keyfile} ${sshuser}@${PRODUCTION} docker run --name ${CONTAINER_NAME} -d -e PORT=5000 -p 80:5000 $USERNAME/$IMAGE_NAME:$IMAGE_TAG
                            '''
                        }
                    }
                }
            }
        }
    }
}