module Academic::Engine
  class ProgramOfferingsController < ApplicationController
    before_action :set_program_offering, only: %i[ show update destroy ]

    # GET /program_offerings
    def index
      @program_offerings = ProgramOffering.all

      render json: @program_offerings
    end

    # GET /program_offerings/1
    def show
      render json: @program_offering
    end

    # POST /program_offerings
    def create
      @program_offering = ProgramOffering.new(program_offering_params)

      if @program_offering.save
        render json: @program_offering, status: :created, location: @program_offering
      else
        render json: @program_offering.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /program_offerings/1
    def update
      if @program_offering.update(program_offering_params)
        render json: @program_offering
      else
        render json: @program_offering.errors, status: :unprocessable_entity
      end
    end

    # DELETE /program_offerings/1
    def destroy
      @program_offering.destroy!
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_program_offering
        @program_offering = ProgramOffering.find(params.expect(:id))
      end

      # Only allow a list of trusted parameters through.
      def program_offering_params
        params.expect(program_offering: [ :program_id, :intake_id, :academic_timeline_id, :mode, :campus ])
      end
  end
end
