# frozen_string_literal: true

class AddressesController < ApplicationController
  def from
    @deliveries = WillPaginate::Collection.create(
      params[:page] || 1,
      WillPaginate.per_page
    ) do |pager|
      result = api_query from: params[:id],
                         limit: pager.per_page,
                         offset: pager.offset
      @data = result.data
      @from = params[:id]
      @stats = @data.emails.statistics

      pager.replace(@data.emails.nodes)
      pager.total_entries = @data.emails.total_count
    end
  end

  def to
    @deliveries = WillPaginate::Collection.create(
      params[:page] || 1,
      WillPaginate.per_page
    ) do |pager|
      result = api_query to: params[:id],
                         limit: pager.per_page,
                         offset: pager.offset

      @data = result.data
      @to = params[:id]
      @stats = @data.emails.statistics
      @deny_lists = @data.blocked_addresses.nodes

      pager.replace(@data.emails.nodes)
      pager.total_entries = @data.emails.total_count
    end
  end
end
