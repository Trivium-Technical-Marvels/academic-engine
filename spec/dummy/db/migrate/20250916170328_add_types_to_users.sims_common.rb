# This migration comes from sims_common (originally 20250913122823)
class AddTypesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :sims_common_users, :types ,:string
    # Example: t.column "first_name", :string
  end
end
