class CreateAcademicEnginePrograms < ActiveRecord::Migration[8.0]
  def change
    create_table :academic_engine_programs do |t|
      t.string :name, null: false, limit: 100
      t.string :code, null: false, limit: 50
      t.integer :duration, null: false
      t.text :description, limit: 500
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :academic_engine_programs, :name, unique: true
    add_index :academic_engine_programs, :code, unique: true
  end
end
