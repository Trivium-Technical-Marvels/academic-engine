# This migration comes from sims_common (originally 20250917102530)
class ChangeNameNullTure < ActiveRecord::Migration[8.0]
  def change
    change_column_null :sims_common_schemas, :name, true
  end
end
