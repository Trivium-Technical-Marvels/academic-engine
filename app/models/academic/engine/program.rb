module Academic::Engine
  class Program < ApplicationRecord
    has_many :program_offerings, dependent: :restrict_with_error, foreign_key: 'academic_engine_program_id'

    with_options presence: true do
      validates :name
      validates :code
      validates :duration
    end

    with_options uniqueness: true do
      validates :name
      validates :code
    end

    validates :duration, numericality: { only_integer: true, greater_than: 0 }


    scope :active, -> { joins(:program_offerings).distinct }
    # Class helpers
    def self.find_by_code(code)
      find_by(code: code.presence)
    end

    def self.find_by_name(name)
      find_by(name: name.presence)
    end

    # Instance helpers
    def active?
      program_offerings.any?
    end

    def duration_in_years
      duration.years
    end
  end
end
