package org.devops

class NotificationService implements Serializable {
    private def script     // Jenkins pipeline script object
    private String slackWebhookUrl

    NotificationService(def script, String slackWebhookUrl) {
        this.script = script
        this.slackWebhookUrl = slackWebhookUrl
    }

    def sendSlack(String message) {
        script.sh """
            curl -s -X POST -H 'Content-type: application/json' \
            --data '{"text":"${message}"}' \
            '${slackWebhookUrl}'
        """
    }

    def sendEmail(String to, String subject, String body) {
        script.mail(
            to: to,
            subject: subject,
            body: body
        )
    }
}