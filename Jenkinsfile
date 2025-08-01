pipeline {
    agent any

    parameters {
        string(name: 'DEPLOY_VERSION', defaultValue: 'v1.0.0', description: 'Deployment version')
        string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'Git branch to checkout')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
    }

    environment {
        REMOTE_USER = 'ubuntu'
        SSH_CREDENTIALS = 'ec2-ssh-key'
        REMOTE_IP = ''
        DEPLOY_DIR = '/home/ubuntu/app'
        BACKUP_DIR = '/home/ubuntu/backup'
    }

    stages {

        stage('Set Target Server') {
            steps {
                script {
                    if (params.ENVIRONMENT == 'dev') {
                        env.REMOTE_IP = '13.232.90.112'
                    } else if (params.ENVIRONMENT == 'staging') {
                        env.REMOTE_IP = '13.232.90.112'
                    } else if (params.ENVIRONMENT == 'prod') {
                        env.REMOTE_IP = '13.232.90.112'
                    }
                    echo "🌐 Target Environment: ${params.ENVIRONMENT}, Deploying to: ${env.REMOTE_IP}"
                }
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: "${params.BRANCH_NAME}", url: 'https://github.com/pranavkadam19/jenkins-devops.git'
            }
        }

        stage('Build') {
            steps {
                sh './build.sh'
            }
        }

        stage('Deploy') {
            steps {
                sshagent (credentials: [env.SSH_CREDENTIALS]) {
                    script {
                        def result = sh (
                            script: """
                            ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_IP} '
                                mkdir -p ${BACKUP_DIR}
                                cp -r ${DEPLOY_DIR} ${BACKUP_DIR}/app_${params.DEPLOY_VERSION} || true
                                rm -rf ${DEPLOY_DIR}
                                mkdir -p ${DEPLOY_DIR}'
                            
                            scp -r ./build/* ${REMOTE_USER}@${REMOTE_IP}:${DEPLOY_DIR}/
                            """,
                            returnStatus: true
                        )

                        if (result != 0) {
                            error("🚨 Deployment failed. Will attempt rollback.")
                        }
                    }
                }
            }
        }

        stage('Rollback') {
            when {
                expression { currentBuild.result == 'FAILURE' }
            }
            steps {
                sshagent (credentials: [env.SSH_CREDENTIALS]) {
                    sh """
                    ssh ${REMOTE_USER}@${REMOTE_IP} '
                        if [ -d "${BACKUP_DIR}/app_${params.DEPLOY_VERSION}" ]; then
                            rm -rf ${DEPLOY_DIR}
                            cp -r ${BACKUP_DIR}/app_${params.DEPLOY_VERSION} ${DEPLOY_DIR}
                        fi
                    '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment of ${params.DEPLOY_VERSION} to ${params.ENVIRONMENT} successful."
        }
        failure {
            echo "⚠️ Deployment failed. Rollback was attempted."
        }
    }
}
