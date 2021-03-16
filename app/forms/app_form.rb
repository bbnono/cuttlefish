# frozen_string_literal: true

class AppForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :click_tracking_enabled, Boolean, default: true
  attribute :open_tracking_enabled, Boolean, default: true
  attribute :custom_tracking_domain, String
  attribute :from_domain, String
  attribute :webhook_url, String
end
