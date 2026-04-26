// Usage: notifySlack(webhookUrl: env.SLACK_URL, message: "Build passed!", color: "good")
def call(Map params) {
    // Validate required parameters
    if (!params.webhookUrl) {
        error("notifySlack: 'webhookUrl' is required")
    }
    if (!params.message) {
        error("notifySlack: 'message' is required")
    }

    String color  = params.color ?: 'good'   // good | warning | danger
    String msg    = params.message
    String webhook = params.webhookUrl

    sh """
        curl -s -X POST -H 'Content-type: application/json' \
        --data '{"attachments":[{"color":"${color}","text":"${msg}"}]}' \
        '${webhook}'
    """
}