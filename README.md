# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

* Create workspace in Slack

* Add slack-notifier gem to Gemfile

```ruby
gem 'slack-notifier'

# config/environments/development.rb
# this will act like a production environment
config.consider_all_requests_local = false

# config/application.rb
# this will tell application to rely on routes to handle the error path to display
config.exceptions_app = self.routes

# config/routes.rb
match "/404", to: "errors#not_foud", via: :all
match "/500", to: "errors#{internal_server_error}", via: :all

rails g controller welcome index about contact

rails g controller errors not_found internal_server_error

#errors_controller.rb
class ErrorsController < ApplicationController
  # layout 'errors'

  def not_found
  end

  def internal_server_error
    begin
      exception = request.env['action_dispatch.exception']
      message = exception.message.to_s
      source_extract = exception.source_extract.join("\n")
      backtrace = exception.backtrace[0..9].join("\n")
      SlackNotifyJob.perform_later(message, source_extract, backtrace)
    ensure
      # head :internal_server_error
      render status: 500
    end
  end
end
```

* Generate SlackNotify active job to handle notify Slack channel

```ruby
rails g job SlackNotify

# ➜  rails5_custom_error_with_slack_notification git:(master) ✗ rails g job SlackNotify
# Running via Spring preloader in process 14396
#       invoke  test_unit
#       create    test/jobs/slack_notify_job_test.rb
#       create  app/jobs/slack_notify_job.rb

class SlackNotifyJob < ApplicationJob
  queue_as :default

  def perform(error_message, source_extract, backtrace)
    error = "Error: 500 - Internal Server Error"
    message = ""
    message << "*#{error}*\n"
    message << "*Date:* #{Time.now}\n"
    message << "*Error:* ```#{error_message}``` \n"
    message << "*Source:* ```#{source_extract}``` \n"
    message << "*Backtrace*: ```#{backtrace}``` \n"
    notifier = Slack::Notifier.new Rails.application.secrets.slack_url
    notifier.ping message, username: '091Error', channel: '#general'
  end
end

# Add slack_url in config/secrets.yml
# go to slack website to create an app and add incoming webhook

```
