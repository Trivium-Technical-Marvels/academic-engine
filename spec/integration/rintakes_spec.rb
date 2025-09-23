require 'swagger_helper'
require 'rails_helper'
RSpec.describe 'Academic::Engine::Intakes API', type: :request do
  let(:current_user) { nil }
  let(:registrar) { build(:registrar) }
  let(:dean) { build(:dean) }
  let(:valid_headers) { { 'ACCEPT' => 'application/json' } }

  path '/academics/intakes' do
    get('List all intakes') do
      tags 'Intakes'
      produces 'application/json'

      response(200, 'successful for registrar') do
        let(:current_user) { registrar }
        before { create_list(:intake, 3, :with_schema) }

        run_test!
      end

      response(200, 'successful for dean') do
        let(:current_user) { dean }
        before { create_list(:intake, 3, :with_schema) }

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

    post('Create an intake') do
      tags 'Intakes'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :payload,
        in: :body,
        schema: {
          type:       :object,
          properties: {
            name:           { type: :string },
            admission_type: { type: :string },
            start_date:     { type: :string, format: :date },
            end_date:       { type: :string, format: :date },
            schema_id:      { type: :integer, description: 'ID of existing requirements schema' }
          },
          required:   %w[name admission_type start_date end_date]
        }

      response(201, 'created by registrar') do
        let(:current_user) { registrar }
        let(:existing_schema) do
          create(:schema,
            name:            'spring_2025_requirements_schema',
            schemaable_type: 'DummyModel',
            schemaable_id:   999_999,
            schema:          {
              '$schema'    => 'https://json-schema.org/draft/2020-12/schema',
              'type'       => 'object',
              'properties' => {
                'gpa' => { 'type' => 'number', 'minimum' => 2.5 }
              },
              'required'   => ['gpa']
            })
        end
        let(:payload) do
          {
            payload: {
              name:           'Spring 2025',
              admission_type: 'spring',
              start_date:     '2025-01-01',
              end_date:       '2025-06-01',
              schema_id:      existing_schema.id
            }
          }
        end
        run_test!
      end

      response(403, 'forbidden for dean') do
        let(:current_user) { dean }
        let(:existing_schema) do
          create(:schema,
            name:            'spring_2025_requirements_schema',
            schemaable_type: 'DummyModel',
            schemaable_id:   999_999,
            schema:          {
              '$schema'    => 'https://json-schema.org/draft/2020-12/schema',
              'type'       => 'object',
              'properties' => {
                'gpa' => { 'type' => 'number', 'minimum' => 2.5 }
              },
              'required'   => ['gpa']
            })
        end
        let(:payload) do
          {
            payload: {
              name:           'Spring 2025',
              admission_type: 'spring',
              start_date:     '2025-01-01',
              end_date:       '2025-06-01',
              schema_id:      existing_schema.id
            }
          }
        end
        run_test!
      end
    end

    path('/academics/intakes/{id}') do
      parameter name: 'id', in: :path, type: :string, description: 'id'

      get('Show an intake') do
        tags 'Intakes'
        produces 'application/json'

        response(200, 'successful for registrar') do
          let(:current_user) { registrar }
          let(:intake) { create(:intake, :with_schema) }
          let(:id) { intake.id }

          run_test!
        end

        response(200, 'successful for dean') do
          let(:current_user) { dean }
          let(:intake) { create(:intake, :with_schema) }
          let(:id) { intake.id }

          run_test!
        end

        response(403, 'forbidden for random user') do
          let(:current_user) { build(:user) }
          let(:intake) { create(:intake, :with_schema) }
          let(:id) { intake.id }

          run_test!
        end

        response(401, 'unauthenticated') do
          let(:current_user) { nil }
          let(:intake) { create(:intake, :with_schema) }
          let(:id) { intake.id }

          run_test!
        end

        response(404, 'not found') do
          let(:current_user) { registrar }
          let(:id) { 'invalid' }

          run_test!
        end
      end

      put('update an intake') do
        tags 'Intakes'
        consumes 'application/json'
        parameter name: :payload,
          in: :body,
          schema: {
            type:       :object,
            properties: {
              name:      { type: :string },
              schema_id: { type: :integer, description: 'ID of existing requirements schema' }
            }
          }
        let(:intake) { create(:intake) }
        let(:id) { intake.id }

        response(200, 'updated by registrar') do
          let(:current_user) { registrar }
          let(:payload) { { payload: { name: 'updated Intake' } } }

          run_test! do |response|
            puts response.status
            puts response.body
          end
        end

        response(403, 'forbidden for dean') do
          let(:current_user) { dean }
          let(:payload) { { payload: { name: 'Dean updated Intake' } } }

          run_test!
        end
      end

      delete('delete an intake') do
        tags 'Intakes'

        let(:intake) { create(:intake) }
        let(:id) { intake.id }

        response(200, 'deleted by registrar') do
          let(:current_user) { registrar }

          run_test!
        end

        response(403, 'forbidden for dean') do
          let(:current_user) { dean }

          run_test!
        end
      end
    end
  end
end
