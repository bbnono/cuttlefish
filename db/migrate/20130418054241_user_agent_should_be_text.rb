# frozen_string_literal: true

class UserAgentShouldBeText < ActiveRecord::Migration[4.2]
  def up
    change_column :open_events, :user_agent, :text, limit: nil
  end

  def down
    change_column :open_events, :user_agent, :string
  end
end
