module Academic::Engine
  class IntakesController < ApplicationController
    before_action :set_intake, only: %i[show update destroy]

    # GET /intakes
    def index
      @intakes = Intake.all

      render json: @intakes
    end

    # GET /intakes/1
    def show
      render json: @intake
    end

    # POST /intakes
    def create
      @intake = Intake.new(intake_params)

      if @intake.save
        render json: @intake, status: :created, location: @intake
      else
        render json: @intake.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /intakes/1
    def update
      if @intake.update(intake_params)
        render json: @intake
      else
        render json: @intake.errors, status: :unprocessable_entity
      end
    end

    # DELETE /intakes/1
    def destroy
      @intake.destroy!
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_intake
      @intake = Intake.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def intake_params
      params.expect(intake: %i[name start_date end_date admission_type])
    end
  end
end
