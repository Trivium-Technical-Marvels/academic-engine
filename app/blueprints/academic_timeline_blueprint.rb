class AcademicTimelineBlueprint < Blueprinter::Base
  
  identifier :id

  fields :name, :start_date, :end_date, :timeline_type, :created_at, :updated_at
end