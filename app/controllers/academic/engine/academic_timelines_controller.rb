module Academic::Engine
  class AcademicTimelinesController < ApplicationController
    before_action :set_academic_timeline, only: %i[ show update destroy ]

    # GET /academic_timelines
    def index
      @academic_timelines = AcademicTimeline.all

      render json: @academic_timelines
    end

    # GET /academic_timelines/1
    def show
      render json: @academic_timeline
    end

    # POST /academic_timelines
    def create
      @academic_timeline = AcademicTimeline.new(academic_timeline_params)

      if @academic_timeline.save
        render json: @academic_timeline, status: :created, location: @academic_timeline
      else
        render json: @academic_timeline.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /academic_timelines/1
    def update
      if @academic_timeline.update(academic_timeline_params)
        render json: @academic_timeline
      else
        render json: @academic_timeline.errors, status: :unprocessable_entity
      end
    end

    # DELETE /academic_timelines/1
    def destroy
      @academic_timeline.destroy!
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_academic_timeline
        @academic_timeline = AcademicTimeline.find(params.expect(:id))
      end

      # Only allow a list of trusted parameters through.
      def academic_timeline_params
        params.expect(academic_timeline: [ :name, :start_date, :end_date, :type ])
      end
  end
end
