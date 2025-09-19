module Academic::Engine
  class Intake < ApplicationRecord

    include JsonSchemaValidatable

    it_validates_against_instance_schemas

    enum :admission_type, { spring: 0, fall: 1 }
    has_many :program_offerings, foreign_key: 'academic_engine_intake_id', dependent: :restrict_with_error
    has_one :requirements_schema, class_name: 'Sims::Common::Schema', as: :schemaable, dependent: :destroy
    accepts_nested_attributes_for :requirements_schema, allow_destroy: true, reject_if: :all_blank

    with_options presence: true do
      validates :name
      validates :admission_type
      validates :start_date
    end




    validates :name, uniqueness: true
    validate :start_date_must_be_on_or_before_end_of_year
    validate :end_date_must_be_on_or_after_start_date
    validate :end_date_must_be_on_or_before_end_of_year

    scope :current, -> { where(start_date: Date.current..Date.current.end_of_year) }

    # Class helpers
    def self.find_by_name(name)
      find_by(name: name.presence)
    end

    def self.find_all_by_admission_type(admission_type)
      where(admission_type: admission_type.presence)
    end

    def self.next_fall
      find_all_by_admission_type(:fall).order(start_date: :asc).first
    end

    def self.next_spring
      find_all_by_admission_type(:spring).order(start_date: :asc).first
    end

    def self.next_intake
      next_fall || next_spring
    end

    def self.previous_fall
      where(admission_type: :fall).order(start_date: :desc).first
    end

    def self.previous_spring
      where(admission_type: :spring).order(start_date: :desc).first
    end

    # Instance helpers
    def active?
      Date.current.between?(start_date, start_date.end_of_year)
    end

    def duration
      (start_date.end_of_year - start_date).to_i.days
    end

    def days_left
      (start_date.end_of_year - Date.current).to_i.days
    end

    def days_till_start
      (start_date - Date.current).to_i.days
    end

    def days_passed_since_start
      (Date.current - start_date).to_i.days
    end

    def end_date
      return super if has_attribute?(:end_date) && super.present?
      return nil if start_date.blank?

      start_date.end_of_year
    end

    def next_intake
      Intake.where('start_date > ?', start_date).order(start_date: :asc).first
    end

    def previous_intake
      Intake.where(start_date: ...start_date).order(start_date: :desc).first
    end

    def next_intake?
      next_intake.present?
    end

    def previous_intake?
      previous_intake.present?
    end

    private

    def start_date_must_be_on_or_before_end_of_year
      return if start_date.blank?

      return unless start_date > Date.current.end_of_year

      errors.add(:start_date, "must be on or before #{Date.current.end_of_year.strftime('%b %d, %Y')}")
    end

    def end_date_must_be_on_or_after_start_date
      return unless start_date.present? && end_date.present?

      return unless end_date < start_date

      errors.add(:end_date, 'must be on or after start date')
    end

    def end_date_must_be_on_or_before_end_of_year
      return if end_date.blank? || start_date.blank?

      return unless end_date > Date.current.end_of_year

      errors.add(:end_date, "must be on or before #{Date.current.end_of_year.strftime('%b %d, %Y')}")
    end
  end
end
