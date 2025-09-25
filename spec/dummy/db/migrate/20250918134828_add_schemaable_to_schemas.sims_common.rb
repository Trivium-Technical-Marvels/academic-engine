# This migration comes from sims_common (originally 20250917090552)
class AddSchemaableToSchemas < ActiveRecord::Migration[8.0]
  def change
    add_reference :sims_common_schemas, :schemaable, polymorphic: true, null: false
  end
end
