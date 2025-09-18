# This migration comes from sims_common (originally 20250913122145)
class CreateSimsCommonUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :sims_common_users do |t|
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
