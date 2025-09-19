module Academic::Engine
  class ProgramOffering < ApplicationRecord
    enum :mode, { full_time: 0, part_time: 1, extension: 2, online: 3 }

    belongs_to :program, foreign_key: 'academic_engine_program_id'
    belongs_to :intake, foreign_key: 'academic_engine_intake_id'
    belongs_to :academic_timeline, foreign_key: 'academic_engine_academic_timeline_id'

    # Create simple aliases for the foreign key columns
    alias_attribute :program_id, :academic_engine_program_id
    alias_attribute :intake_id, :academic_engine_intake_id
    alias_attribute :academic_timeline_id, :academic_engine_academic_timeline_id

    with_options presence: true do
      validates :mode
    end

    scope :full_time, -> { where(mode: :full_time) }
    scope :part_time, -> { where(mode: :part_time) }
    scope :extension, -> { where(mode: :extension) }
    scope :online, -> { where(mode: :online) }
    scope :current, -> { where(intake: Intake.current) }

    # Class helpers
    def self.find_by_program_and_intake(program, intake)
      where(program: program.presence, intake: intake.presence).first
    end

    def self.find_all_by_program_and_academic_timeline(program, academic_timeline)
      where(program: program.presence, academic_timeline: academic_timeline.presence)
    end

    def self.find_by_mode_and_program(mode, program)
      where(mode: mode.presence, program: program.presence).first
    end

    def self.find_all_by_academic_timeline(academic_timeline)
      where(academic_timeline: academic_timeline.presence)
    end

    def self.find_all_by_intake(intake)
      where(intake: intake.presence)
    end

    def self.find_all_by_program(program)
      where(program: program.presence)
    end

    # Instance helpers
    delegate :name, to: :intake, prefix: true
    delegate :admission_type, to: :intake, prefix: true
    delegate :start_date, to: :intake, prefix: true
    delegate :end_date, to: :intake, prefix: true
    delegate :days_left, to: :intake, prefix: true
    delegate :days_till_start, to: :intake, prefix: true
    delegate :days_passed_since_start, to: :intake, prefix: true
    delegate :active?, to: :intake, prefix: true
    delegate :intake_duration, to: :intake, prefix: true

    delegate :name, to: :program, prefix: true
    delegate :code, to: :program, prefix: true
    delegate :degree_type, to: :program, prefix: true
    delegate :degree_type_code, to: :program, prefix: true
    delegate :duration, to: :program, prefix: true
    delegate :description, to: :program, prefix: true
    def timeline
      academic_timeline&.name
    end
  end
end
