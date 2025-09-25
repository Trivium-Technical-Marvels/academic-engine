module Academic::Engine
  class AcademicTimeline < ApplicationRecord
    self.inheritance_column = nil

    has_many :program_offerings, dependent: :restrict_with_error, foreign_key: 'academic_engine_academic_timeline_id'

    enum :timeline_type, { semester: 0, quarter: 1, trimester: 2 }

    with_options presence: true do
      validates :name
      validates :start_date
      validates :end_date
    end
    validates :name, uniqueness: true
    validate :end_date_must_be_on_or_after_start_date
    validate :start_date_must_be_on_or_before_end_date

    validates :name, length: { maximum: 100 }

    # Class methods
    def self.find_by_name(name)
      find_by(name: name.presence)
    end

    def self.find_all_by_year(year)
      where('EXTRACT(YEAR FROM start_date) = ?', year.presence.to_i)
    end

    # Instance helpers
    def active?
      Date.current.between?(start_date, end_date)
    end

    def duration
      ((end_date - start_date).to_i + 1).days
    end

    def days_left
      (end_date - Date.current).to_i.days
    end

    def days_till_start
      (start_date - Date.current).to_i
    end

    def days_passed_since_start
      (Date.current - start_date).to_i
    end

    private

    def end_date_must_be_on_or_after_start_date
      return unless start_date.present? && end_date.present?

      return unless end_date < start_date

      errors.add(:end_date, "must be after start date (#{start_date})")
    end

    def start_date_must_be_on_or_before_end_date
      return unless start_date.present? && end_date.present?

      return unless start_date > end_date

      errors.add(:start_date, "must be before end date (#{end_date})")
    end
  end
end
