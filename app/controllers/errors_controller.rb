class ErrorsController < ApplicationController
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
      render status: 500
    end
  end
end
