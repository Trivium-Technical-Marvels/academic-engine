require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Academic::Engine::ProgramOfferings API', type: :request do
  let(:current_user) { nil }
  let(:registrar) { build(:registrar) }
  let(:dean) { build(:dean) }

  # shared associations for program_offering creation
  let(:program) { create(:program) }
  let(:intake) { create(:intake) }
  let(:academic_timeline) { create(:academic_timeline) }

  path '/academics/program_offerings' do
    get('List all program offerings') do
      tags 'Program Offerings'
      produces 'application/json'

      response(200, 'successful for registrar') do
        let(:current_user) { registrar }
        before { create_list(:program_offering, 3) }

        schema type: :object,
          properties: {
            payload: {
              type:       :object,
              properties: {
                records: {
                  type:  :array,
                  items: {
                    type:       :object,
                    properties: {
                      id:                { type: :integer },
                      active:            { type: :boolean },
                      mode:              { type: :string },
                      campus:            { type: :string },
                      program:           {
                        type:       :object,
                        properties: {
                          id:       { type: :integer },
                          name:     { type: :string },
                          code:     { type: :string },
                          duration: { type: :integer },
                          active:   { type: :boolean }
                        },
                        required:   %w[id name code duration active]
                      },
                      intake:            {
                        type:       :object,
                        properties: {
                          id:             { type: :integer },
                          name:           { type: :string },
                          admission_type: { type: :string },
                          start_date:     { type: :string, format: :date },
                          end_date:       { type: :string, format: :date },
                          created_at:     { type: :string, format: :datetime },
                          updated_at:     { type: :string, format: :datetime }
                        },
                        required:   %w[id name admission_type start_date end_date created_at updated_at]
                      },
                      academic_timeline: {
                        type:       :object,
                        properties: {
                          id:            { type: :integer },
                          name:          { type: :string },
                          start_date:    { type: :string, format: :date },
                          end_date:      { type: :string, format: :date },
                          timeline_type: { type: :string },
                          created_at:    { type: :string, format: :datetime },
                          updated_at:    { type: :string, format: :datetime }
                        },
                        required:   %w[id name start_date end_date timeline_type created_at updated_at]
                      }
                    },
                    required:   %w[id active mode campus program intake academic_timeline]
                  }
                }
              },
              required:   %w[records]
            },
            meta:    {
              type:       :object,
              properties: {
                pagination: { type: :object }
              }
            }
          },
          required: %w[payload meta]

        run_test!
      end

      response(200, 'successful for dean') do
        let(:current_user) { dean }
        before { create_list(:program_offering, 3) }

        schema type: :object,
          properties: {
            payload: {
              type:       :object,
              properties: {
                records: {
                  type:  :array,
                  items: {
                    type:       :object,
                    properties: {
                      id:                { type: :integer },
                      active:            { type: :boolean },
                      mode:              { type: :string },
                      campus:            { type: :string },
                      program:           {
                        type:       :object,
                        properties: {
                          id:       { type: :integer },
                          name:     { type: :string },
                          code:     { type: :string },
                          duration: { type: :integer },
                          active:   { type: :boolean }
                        },
                        required:   %w[id name code duration active]
                      },
                      intake:            {
                        type:       :object,
                        properties: {
                          id:             { type: :integer },
                          name:           { type: :string },
                          admission_type: { type: :string },
                          start_date:     { type: :string, format: :date },
                          end_date:       { type: :string, format: :date },
                          created_at:     { type: :string, format: :datetime },
                          updated_at:     { type: :string, format: :datetime }
                        },
                        required:   %w[id name admission_type start_date end_date created_at updated_at]
                      },
                      academic_timeline: {
                        type:       :object,
                        properties: {
                          id:            { type: :integer },
                          name:          { type: :string },
                          start_date:    { type: :string, format: :date },
                          end_date:      { type: :string, format: :date },
                          timeline_type: { type: :string },
                          created_at:    { type: :string, format: :datetime },
                          updated_at:    { type: :string, format: :datetime }
                        },
                        required:   %w[id name start_date end_date timeline_type created_at updated_at]
                      }
                    },
                    required:   %w[id active mode campus program intake academic_timeline]
                  }
                }
              },
              required:   %w[records]
            },
            meta:    {
              type:       :object,
              properties: {
                pagination: { type: :object }
              }
            }
          },
          required: %w[payload meta]

        run_test!
      end

      response(403, 'forbidden for random user') do
        let(:current_user) { build(:user) }
        run_test!
      end

      response(401, 'unauthenticated') do
        let(:current_user) { nil }
        run_test!
      end
    end

    post('Create a program offering') do
      tags 'Program Offerings'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :payload,
        in: :body,
        schema: {
          type:       :object,
          properties: {
            payload: {
              type:       :object,
              properties: {
                active:               { type: :boolean },
                mode:                 { type: :string },
                campus:               { type: :string },
                program_id:           { type: :integer },
                intake_id:            { type: :integer },
                academic_timeline_id: { type: :integer }
              },
              required:   %w[active mode campus program_id intake_id academic_timeline_id]
            }
          },
          required:   %w[payload]
        }

      response(201, 'created by registrar') do
        let(:current_user) { registrar }
        let(:payload) do
          {
            payload: {
              active:               true,
              mode:                 'full_time',
              campus:               'Main Campus',
              program_id:           program.id,
              intake_id:            intake.id,
              academic_timeline_id: academic_timeline.id
            }
          }
        end

        schema type: :object,
          properties: {
            payload: {
              type:       :object,
              properties: {
                record: {
                  type:       :object,
                  properties: {
                    id:                { type: :integer },
                    active:            { type: :boolean },
                    mode:              { type: :string },
                    campus:            { type: :string },
                    program:           {
                      type:       :object,
                      properties: {
                        id:       { type: :integer },
                        name:     { type: :string },
                        code:     { type: :string },
                        duration: { type: :integer },
                        active:   { type: :boolean }
                      },
                      required:   %w[id name code duration active]
                    },
                    intake:            {
                      type:       :object,
                      properties: {
                        id:             { type: :integer },
                        name:           { type: :string },
                        admission_type: { type: :string },
                        start_date:     { type: :string, format: :date },
                        end_date:       { type: :string, format: :date },
                        created_at:     { type: :string, format: :datetime },
                        updated_at:     { type: :string, format: :datetime }
                      },
                      required:   %w[id name admission_type start_date end_date created_at updated_at]
                    },
                    academic_timeline: {
                      type:       :object,
                      properties: {
                        id:            { type: :integer },
                        name:          { type: :string },
                        start_date:    { type: :string, format: :date },
                        end_date:      { type: :string, format: :date },
                        timeline_type: { type: :string },
                        created_at:    { type: :string, format: :datetime },
                        updated_at:    { type: :string, format: :datetime }
                      },
                      required:   %w[id name start_date end_date timeline_type created_at updated_at]
                    }
                  },
                  required:   %w[id active mode campus program intake academic_timeline]
                }
              },
              required:   %w[record]
            },
            meta:    {
              type:       :object,
              properties: {
                pagination: { type: :object }
              }
            }
          },
          required: %w[payload meta]

        run_test!
      end

      response(403, 'forbidden for dean') do
        let(:current_user) { dean }
        let(:payload) do
          {
            payload: {
              active:               true,
              mode:                 'full_time',
              campus:               'City Campus',
              program_id:           program.id,
              intake_id:            intake.id,
              academic_timeline_id: academic_timeline.id
            }
          }
        end

        run_test!
      end

      response(401, 'unauthenticated') do
        let(:current_user) { nil }
        let(:payload) do
          {
            payload: {
              active:               true,
              mode:                 'full_time',
              campus:               'Virtual Campus',
              program_id:           program.id,
              intake_id:            intake.id,
              academic_timeline_id: academic_timeline.id
            }
          }
        end

        run_test!
      end
    end
  end

  path '/academics/program_offerings/{id}' do
    parameter name: :id, in: :path, type: :string

    get('Show a program offering') do
      tags 'Program Offerings'
      produces 'application/json'

      response(200, 'successful for registrar') do
        let(:current_user) { registrar }
        let(:program_offering) { create(:program_offering) }
        let(:id) { program_offering.id }

        schema type: :object,
          properties: {
            payload: {
              type:       :object,
              properties: {
                record: {
                  type:       :object,
                  properties: {
                    id:                { type: :integer },
                    active:            { type: :boolean },
                    mode:              { type: :string },
                    campus:            { type: :string },
                    program:           {
                      type:       :object,
                      properties: {
                        id:       { type: :integer },
                        name:     { type: :string },
                        code:     { type: :string },
                        duration: { type: :integer },
                        active:   { type: :boolean }
                      },
                      required:   %w[id name code duration active]
                    },
                    intake:            {
                      type:       :object,
                      properties: {
                        id:             { type: :integer },
                        name:           { type: :string },
                        admission_type: { type: :string },
                        start_date:     { type: :string, format: :date },
                        end_date:       { type: :string, format: :date },
                        created_at:     { type: :string, format: :datetime },
                        updated_at:     { type: :string, format: :datetime }
                      },
                      required:   %w[id name admission_type start_date end_date created_at updated_at]
                    },
                    academic_timeline: {
                      type:       :object,
                      properties: {
                        id:            { type: :integer },
                        name:          { type: :string },
                        start_date:    { type: :string, format: :date },
                        end_date:      { type: :string, format: :date },
                        timeline_type: { type: :string },
                        created_at:    { type: :string, format: :datetime },
                        updated_at:    { type: :string, format: :datetime }
                      },
                      required:   %w[id name start_date end_date timeline_type created_at updated_at]
                    }
                  },
                  required:   %w[id active mode campus program intake academic_timeline]
                }
              },
              required:   %w[record]
            },
            meta:    {
              type:       :object,
              properties: {
                pagination: { type: :object }
              }
            }
          },
          required: %w[payload meta]

        run_test!
      end

      response(404, 'not found') do
        let(:current_user) { registrar }
        let(:id) { 'non-existent' }

        run_test!
      end
    end

    put('Update a program offering') do
      tags 'Program Offerings'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :payload,
        in: :body,
        schema: {
          type:       :object,
          properties: {
            payload: {
              type:       :object,
              properties: {
                active: { type: :boolean },
                mode:   { type: :string },
                campus: { type: :string }
              },
              required:   %w[active mode campus]
            }
          },
          required:   %w[payload]
        }

      response(200, 'updated by registrar') do
        let(:current_user) { registrar }
        let(:program_offering) { create(:program_offering) }
        let(:id) { program_offering.id }
        let(:payload) do
          {
            payload: {
              active: false,
              mode:   'extension',
              campus: 'North Campus'
            }
          }
        end

        schema type: :object,
          properties: {
            payload: {
              type:       :object,
              properties: {
                record: {
                  type:       :object,
                  properties: {
                    id:                { type: :integer },
                    active:            { type: :boolean },
                    mode:              { type: :string },
                    campus:            { type: :string },
                    program:           {
                      type:       :object,
                      properties: {
                        id:       { type: :integer },
                        name:     { type: :string },
                        code:     { type: :string },
                        duration: { type: :integer },
                        active:   { type: :boolean }
                      },
                      required:   %w[id name code duration active]
                    },
                    intake:            {
                      type:       :object,
                      properties: {
                        id:             { type: :integer },
                        name:           { type: :string },
                        admission_type: { type: :string },
                        start_date:     { type: :string, format: :date },
                        end_date:       { type: :string, format: :date },
                        created_at:     { type: :string, format: :datetime },
                        updated_at:     { type: :string, format: :datetime }
                      },
                      required:   %w[id name admission_type start_date end_date created_at updated_at]
                    },
                    academic_timeline: {
                      type:       :object,
                      properties: {
                        id:            { type: :integer },
                        name:          { type: :string },
                        start_date:    { type: :string, format: :date },
                        end_date:      { type: :string, format: :date },
                        timeline_type: { type: :string },
                        created_at:    { type: :string, format: :datetime },
                        updated_at:    { type: :string, format: :datetime }
                      },
                      required:   %w[id name start_date end_date timeline_type created_at updated_at]
                    }
                  },
                  required:   %w[id active mode campus program intake academic_timeline]
                }
              },
              required:   %w[record]
            },
            meta:    {
              type:       :object,
              properties: {
                pagination: { type: :object }
              }
            }
          },
          required: %w[payload meta]

        run_test!
      end
    end

    delete('Delete a program offering') do
      tags 'Program Offerings'
      produces 'application/json'

      response(200, 'deleted by registrar') do
        let(:current_user) { registrar }
        let(:program_offering) { create(:program_offering) }
        let(:id) { program_offering.id }

        schema type: :object,
          properties: {
            payload: {
              type:       :object,
              properties: {
                message: { type: :string }
              },
              required:   %w[message]
            },
            meta:    {
              type:       :object,
              properties: {
                pagination: { type: :object }
              }
            }
          },
          required: %w[payload meta]

        run_test!
      end
    end
  end
end
