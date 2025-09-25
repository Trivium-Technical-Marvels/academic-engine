class IntakeBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :admission_type, :start_date, :end_date, :created_at, :updated_at

  association :requirements_schema, blueprint: SchemaBlueprint
end
