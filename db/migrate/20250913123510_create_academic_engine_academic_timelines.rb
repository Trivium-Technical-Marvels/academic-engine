class CreateAcademicEngineAcademicTimelines < ActiveRecord::Migration[8.0]
  def change
    create_table :academic_engine_academic_timelines do |t|
      t.string :name, null: false, limit: 100
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :type, null: false

      t.timestamps
    end
    add_index :academic_engine_academic_timelines, :name, unique: true
  end
end
