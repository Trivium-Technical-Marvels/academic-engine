class RemoveDescriptionFromAcademicEnginePrograms < ActiveRecord::Migration[8.0]
  def change
    remove_column :academic_engine_programs, :description, :text
  end
end
