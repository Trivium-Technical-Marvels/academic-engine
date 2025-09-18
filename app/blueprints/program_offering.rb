class ProgramOfferingBlueprint < Blueprinter::Base
  identifier :id
  fields :program_id, :intake_id, :academic_timeline_id, :active, :mode, :campus
end