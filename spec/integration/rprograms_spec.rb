require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Academic::Engine::Programs API', type: :request do
  let(:current_user) { nil }
  let(:registrar) { build(:registrar) }
  let(:dean) { build(:dean) }

  path '/academics/programs' do
    get('List all programs') do
      tags 'Programs'
      produces 'application/json'

      response(200, 'successful for registrar') do
        let(:current_user) { registrar }
        before { create_list(:program, 3) }

        run_test!
      end

      response(200, 'successful for dean') do
        let(:current_user) { dean }
        before { create_list(:program, 3) }

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

    post('Create a program') do
      tags 'Programs'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          code: { type: :string },
          duration: { type: :integer },
          active: { type: :boolean }, },
        required: %w[name code duration], }

      response(201, 'created by registrar') do
        let(:current_user) { registrar }
        let(:payload) do
          {
            payload: {
              name: 'Computer Science',
              code: 'CS101',
              duration: 4,
              active: true, } }
        end
        run_test!
      end

      response(403, 'forbidden for dean') do
        let(:current_user) { dean }
        let(:payload) { { payload: { name: 'CS', code: 'CS99', duration: 3, active: true } } }
        run_test!
      end

      response(401, 'unauthenticated') do
        let(:current_user) { nil }
        let(:payload) { { payload: { name: 'CS', code: 'CS99', duration: 3, active: true } } }
        run_test!
      end
    end
  end

  path '/academics/programs/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'Program ID'

    get('Show a program') do
      tags 'Programs'
      produces 'application/json'

      response(200, 'successful for registrar') do
        let(:current_user) { registrar }
        let(:program) { create(:program) }
        let(:id) { program.id }

        run_test!
      end
      response(200, 'successful for dean') do
        let(:current_user) { dean }
        let(:program) { create(:program) }
        let(:id) { program.id }

        response(404, 'not found') do
          let(:current_user) { registrar }
          let(:id) { 'invalid' }
          run_test!
        end
      end

      put('Update a program') do
        tags 'Programs'
        consumes 'application/json'
        parameter name: :payload, in: :body, schema: {
          type: :object,
          properties: { name: { type: :string } }, }

        let(:program) { create(:program) }
        let(:id) { program.id }

        response(200, 'updated by registrar') do
          let(:current_user) { registrar }
          let(:payload) { { payload: { name: 'Updated Program' } } }
          run_test!
        end

        response(403, 'forbidden for dean') do
          let(:current_user) { dean }
          let(:payload) { { payload: { name: 'Updated Program' } } }
          run_test!
        end
        response(401, 'unauthenticated') do
          let(:current_user) { nil }
          let(:payload) { { payload: { name: 'Updated Program' } } }
          run_test!
        end
      end

      delete('Delete a program') do
        tags 'Programs'
        let(:program) { create(:program) }
        let(:id) { program.id }

        response(200, 'deleted by registrar') do
          let(:current_user) { registrar }
          run_test!
        end
        response(403, 'forbidden for dean') do
          let(:current_user) { dean }
          run_test!
        end
        response(401, 'unauthenticated') do
          let(:current_user) { nil }
          let(:id) { program.id }
          run_test!
        end
      end
    end
  end
end
