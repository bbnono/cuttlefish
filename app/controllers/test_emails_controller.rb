# frozen_string_literal: true

class TestEmailsController < ApplicationController
  # We're using the simple_format helper below. Ugly but quick by bringing it
  # into the controller
  include ActionView::Helpers::TextHelper

  def new
    result = api_query
    @data = result.data
    @to = helpers.email_with_name(@data.viewer)
    @subject = "This is a test email from Cuttlefish"
    @text = <<~TEXT
      Hello folks. Hopefully this should have worked and you should
      be reading this. So, all is good.

      Love,
      The Awesome Cuttlefish
      <a href="http://cuttlefish.io">http://cuttlefish.io</a>
    TEXT
  end

  # Send a test email
  def create
    # TODO: Check for errors
    api_query app_id: params[:app_id],
              from: params[:from],
              to: params[:to],
              cc: params[:cc],
              subject: params[:subject],
              textPart: params[:text],
              htmlPart: simple_format(params[:text])

    flash[:notice] = "Test email sent"
    redirect_to deliveries_url
  end
end
