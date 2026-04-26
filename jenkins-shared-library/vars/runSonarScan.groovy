// Usage: runSonarScan(projectKey: 'devops-app', srcDir: '.', lcovReport: 'coverage/lcov.info')
def call(Map params) {
    ['projectKey', 'srcDir'].each { key ->
        if (!params[key]) error("runSonarScan: '${key}' is required")
    }

    String projectKey = params.projectKey
    String srcDir     = params.srcDir
    String lcov       = params.lcovReport ?: ''

    withSonarQubeEnv('SonarQube') {
        sh """
            cd ${srcDir}
            npx sonar-scanner \
              -Dsonar.projectKey=${projectKey} \
              -Dsonar.sources=. \
              ${lcov ? "-Dsonar.javascript.lcov.reportPaths=${lcov}" : ''}
        """
    }

    timeout(time: 5, unit: 'MINUTES') {
        waitForQualityGate abortPipeline: true
    }
}