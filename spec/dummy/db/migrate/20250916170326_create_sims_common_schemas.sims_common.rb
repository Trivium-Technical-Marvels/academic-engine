# This migration comes from sims_common (originally 20250912151045)
class CreateSimsCommonSchemas < ActiveRecord::Migration[8.0]
  def change
    create_table :sims_common_schemas do |t|
      t.string :name, null: false
      t.json :schema, null: false

      t.timestamps
      t.index :name, unique: true
    end
  end
end
