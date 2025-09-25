class ProgramOfferingBlueprint < Blueprinter::Base
  identifier :id
  fields :active, :mode, :campus

  association :program, blueprint: ProgramBlueprint
  association :intake, blueprint: IntakeBlueprint
  association :academic_timeline, blueprint: AcademicTimelineBlueprint
end
