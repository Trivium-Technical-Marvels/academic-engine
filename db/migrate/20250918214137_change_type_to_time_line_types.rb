class ChangeTypeToTimeLineTypes < ActiveRecord::Migration[8.0]
  def change
    rename_column :academic_engine_academic_timelines, :type, :timeline_type
  end
end
