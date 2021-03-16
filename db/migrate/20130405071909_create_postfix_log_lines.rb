# frozen_string_literal: true

class CreatePostfixLogLines < ActiveRecord::Migration[4.2]
  def change
    create_table :postfix_log_lines do |t|
      t.string :text
      t.references :email

      t.timestamps
    end
  end
end
