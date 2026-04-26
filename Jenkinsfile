@Library('jenkins-shared-library') _

pipeline {
    agent { label 'linux-agent' }

    environment {
        APP_DIR       = 'assignment-4/app'
        SLACK_WEBHOOK = credentials('slack-webhook-url')
        GIT_SHORT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    }

    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo "Branch : ${env.BRANCH_NAME}"
                echo "Commit : ${env.GIT_SHORT_SHA}"
            }
        }

        stage('Build') {
            steps {
                dir("${APP_DIR}") {
                    sh '''
                        echo "=== Installing dependencies ==="
                        npm ci
                        echo "=== Build complete ==="
                    '''
                }
            }
        }

        stage('Test') {
            parallel {

                stage('Unit Tests') {
                    steps {
                        dir("${APP_DIR}") {
                            sh '''
                                echo "=== Running Unit Tests ==="
                                JEST_JUNIT_OUTPUT_DIR=test-results \
                                JEST_JUNIT_OUTPUT_NAME=unit-junit.xml \
                                npx jest tests/unit \
                                    --coverage \
                                    --coverageReporters=cobertura \
                                    --coverageReporters=lcov \
                                    --coverageReporters=text \
                                    --reporters=default \
                                    --reporters=jest-junit \
                                    --forceExit
                            '''
                        }
                    }
                    post {
                        always {
                            junit allowEmptyResults: true,
                                  testResults: "${APP_DIR}/test-results/unit-junit.xml"
                        }
                    }
                }

                stage('Integration Tests') {
                    steps {
                        dir("${APP_DIR}") {
                            sh '''
                                echo "=== Running Integration Tests ==="
                                JEST_JUNIT_OUTPUT_DIR=test-results \
                                JEST_JUNIT_OUTPUT_NAME=integration-junit.xml \
                                npx jest tests/integration \
                                    --reporters=default \
                                    --reporters=jest-junit \
                                    --forceExit
                            '''
                        }
                    }
                    post {
                        always {
                            junit allowEmptyResults: true,
                                  testResults: "${APP_DIR}/test-results/integration-junit.xml"
                        }
                    }
                }

            }
        }

        stage('Package') {
            steps {
                dir("${APP_DIR}") {
                    sh '''
                        echo "=== Packaging application ==="
                        tar --exclude=node_modules \
                            --exclude=coverage \
                            --exclude=test-results \
                            -czf ../../app-${BUILD_NUMBER}-${GIT_SHORT_SHA}.tar.gz .
                        echo "=== Package ready ==="
                        ls -lh ../../app-${BUILD_NUMBER}-${GIT_SHORT_SHA}.tar.gz
                    '''
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                echo "=== Deploy stage (Task 5: ECR push will be added here) ==="
                echo "Build #${env.BUILD_NUMBER} | Commit: ${env.GIT_SHORT_SHA} | Branch: ${env.BRANCH_NAME}"
            }
        }

    }

    post {

        always {
            echo "=== Archiving build artifacts ==="
            archiveArtifacts artifacts: 'app-*.tar.gz',
                             allowEmptyArchive: true
            archiveArtifacts artifacts: "${APP_DIR}/coverage/**",
                             allowEmptyArchive: true
            cleanWs()
        }

        // Task 3: Using notifySlack from jenkins-shared-library
        success {
            notifySlack(
                webhookUrl: env.SLACK_WEBHOOK,
                color: 'good',
                message: ":white_check_mark: *BUILD SUCCEEDED*\n*Job:* ${env.JOB_NAME}\n*Branch:* ${env.BRANCH_NAME}\n*Build:* #${env.BUILD_NUMBER}\n*Commit:* ${env.GIT_SHORT_SHA}\n*Duration:* ${currentBuild.durationString}\n*URL:* ${env.BUILD_URL}"
            )
        }

        failure {
            notifySlack(
                webhookUrl: env.SLACK_WEBHOOK,
                color: 'danger',
                message: ":x: *BUILD FAILED*\n*Job:* ${env.JOB_NAME}\n*Branch:* ${env.BRANCH_NAME}\n*Build:* #${env.BUILD_NUMBER}\n*Commit:* ${env.GIT_SHORT_SHA}\n*Result:* ${currentBuild.result}\n*URL:* ${env.BUILD_URL}\nCheck the console output for the failing stage."
            )
        }

    }
}
