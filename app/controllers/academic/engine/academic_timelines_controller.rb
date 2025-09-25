module Academic::Engine
  class AcademicTimelinesController < ApplicationController
    include CrudActions

    %w[index show create update destroy].each do |action|
      method_body = 'index destroy'.include?(action) ? proc { super(false) } : proc { super(has_policy: false) }
      define_method(action, &method_body)
    end

    private

    def model_params
      params.expect(payload: %i[name start_date end_date timeline_type])
    end
  end
end
