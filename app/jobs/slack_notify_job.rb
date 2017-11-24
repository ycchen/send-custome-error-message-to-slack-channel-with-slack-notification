class SlackNotifyJob < ApplicationJob
  queue_as :default

  def perform(error_message, source_extract, backtrace)
    error = "Error: 500 - Internal Server Error"
    message = ""
    message << "*#{error}*\n"
    message << "*Date:* #{Time.now}*\n"
    message << "*Error:* ```#{error_message} ```\n"
    message << "*Source:* ```#{source_extract} ```\n"
    message << "*BackTrace:* ```#{backtrace} ```\n"
    notifier = Slack::Notifier.new Rails.application.secrets.slack_url
    notifier.ping message, username: '091Error', channel: '#general'
  end
end
