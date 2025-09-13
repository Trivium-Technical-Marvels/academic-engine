class CreateAcademicEngineProgramOfferings < ActiveRecord::Migration[8.0]
  def change
    create_table :academic_engine_program_offerings do |t|
      t.belongs_to :academic_engine_program, null: false, foreign_key: true
      t.belongs_to :academic_engine_intake, null: false, foreign_key: true
      t.belongs_to :academic_engine_academic_timeline, null: false, foreign_key: true
      t.integer :mode, null: false
      t.string :campus, null: false, limit: 50
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
