require 'rails_helper'
require 'swagger_helper'
RSpec.describe 'Academic::Engine::Timelines API', type: :request do
  let(:current_user) { nil }
  let(:registrar) { build(:registrar) }
  let(:dean) { build(:dean) }
  let(:valid_headers) { { 'ACCEPT' => 'application/json' } }

  path '/academics/academic_timelines' do
    get('List all academic timelines') do
      tags 'Academic Timelines'
      produces 'application/json'

      response(200, 'successful for registrar') do
        let(:current_user) { registrar }
        before { create_list(:academic_timeline, 3) }

        schema type: :object,
               properties: {
                 payload: {
                   type: :object,
                   properties: {
                     records: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           name: { type: :string },
                           start_date: { type: :string, format: :date },
                           end_date: { type: :string, format: :date },
                           timeline_type: { type: :string },
                           created_at: { type: :string, format: :datetime },
                           updated_at: { type: :string, format: :datetime }, },
                         required: %w[id name start_date end_date timeline_type created_at updated_at], }, } },
                   required: %w[records], },
                 meta: {
                   type: :object,
                   properties: {
                     pagination: { type: :object } }, }, },
               required: %w[payload meta]

        run_test!
      end

      response(200, 'successful for dean') do
        let(:current_user) { dean }
        before { create_list(:academic_timeline, 3) }

        schema type: :object,
               properties: {
                 payload: {
                   type: :object,
                   properties: {
                     records: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           name: { type: :string },
                           start_date: { type: :string, format: :date },
                           end_date: { type: :string, format: :date },
                           timeline_type: { type: :string },
                           created_at: { type: :string, format: :datetime },
                           updated_at: { type: :string, format: :datetime }, },
                         required: %w[id name start_date end_date timeline_type created_at updated_at], }, } },
                   required: %w[records], },
                 meta: {
                   type: :object,
                   properties: {
                     pagination: { type: :object } }, }, },
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
    post('Create an academic timeline') do
      tags 'Academic Timelines'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          start_date: { type: :string, format: :date },
          end_date: { type: :string, format: :date },
          timeline_type: { type: :string }, },
        required: %w[name start_date end_date timeline_type], }

      response(201, 'created by registrar') do
        let(:current_user) { registrar }
        let(:payload) do
          {
            payload: {
              name: 'First Semester 2024',
              start_date: '2024-01-01',
              end_date: '2024-06-30',
              timeline_type: 'semester', } }
        end

        schema type: :object,
               properties: {
                 payload: {
                   type: :object,
                   properties: {
                     record: {
                       type: :object,
                       properties: {
                         id: { type: :integer },
                         name: { type: :string },
                         start_date: { type: :string, format: :date },
                         end_date: { type: :string, format: :date },
                         timeline_type: { type: :string },
                         created_at: { type: :string, format: :datetime },
                         updated_at: { type: :string, format: :datetime }, },
                       required: %w[id name start_date end_date timeline_type created_at updated_at], } },
                   required: %w[record], },
                 meta: {
                   type: :object,
                   properties: {
                     pagination: { type: :object } }, }, },
               required: %w[payload meta]

        run_test!
      end

      response(403, 'forbidden for dean') do
        let(:current_user) { dean }
        let(:payload) do
          {
            payload: {
              name: 'First Semester 2024',
              start_date: '2024-01-01',
              end_date: '2024-06-30',
              timeline_type: 'semester', } }
        end

        run_test!
      end

      response(403, 'forbidden for random user') do
        let(:current_user) { build(:user) }
        let(:payload) do
          {
            payload: {
              name: 'First Semester 2024',
              start_date: '2024-01-01',
              end_date: '2024-06-30',
              timeline_type: 'semester', } }
        end

        run_test!
      end

      response(401, 'unauthenticated') do
        let(:current_user) { nil }
        let(:payload) do
          {
            payload: {
              name: 'First Semester 2024',
              start_date: '2024-01-01',
              end_date: '2024-06-30',
              timeline_type: 'semester', } }
        end
        run_test!
      end
    end
    path('/academics/academic_timelines/{id}') do
      parameter name: 'id', in: :path, type: :string, description: 'id'

      get('Show an academic timeline') do
        tags 'Academic Timelines'
        produces 'application/json'

        response(200, 'successful for registrar') do
          let(:current_user) { registrar }
          let(:id) { create(:academic_timeline).id }

          schema type: :object,
                 properties: {
                   payload: {
                     type: :object,
                     properties: {
                       record: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           name: { type: :string },
                           start_date: { type: :string, format: :date },
                           end_date: { type: :string, format: :date },
                           timeline_type: { type: :string },
                           created_at: { type: :string, format: :datetime },
                           updated_at: { type: :string, format: :datetime }, },
                         required: %w[id name start_date end_date timeline_type created_at updated_at], } },
                     required: %w[record], },
                   meta: {
                     type: :object,
                     properties: {
                       pagination: { type: :object } }, }, },
                 required: %w[payload meta]

          run_test!
        end

        response(200, 'successful for dean') do
          let(:current_user) { dean }
          let(:id) { create(:academic_timeline).id }

          schema type: :object,
                 properties: {
                   payload: {
                     type: :object,
                     properties: {
                       record: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           name: { type: :string },
                           start_date: { type: :string, format: :date },
                           end_date: { type: :string, format: :date },
                           timeline_type: { type: :string },
                           created_at: { type: :string, format: :datetime },
                           updated_at: { type: :string, format: :datetime }, },
                         required: %w[id name start_date end_date timeline_type created_at updated_at], } },
                     required: %w[record], },
                   meta: {
                     type: :object,
                     properties: {
                       pagination: { type: :object } }, }, },
                 required: %w[payload meta]

          run_test!
        end

        response(403, 'forbidden for random user') do
          let(:current_user) { build(:user) }
          let(:id) { create(:academic_timeline).id }

          run_test!
        end

        response(401, 'unauthenticated') do
          let(:current_user) { nil }
          let(:id) { create(:academic_timeline).id }

          run_test!
        end

        response(404, 'not found') do
          let(:current_user) { registrar }
          let(:id) { 'invalid' }

          run_test!
        end
      end

      put('update an academic timeline') do
        tags 'Academic Timelines'
        consumes 'application/json'
        parameter name: :payload, in: :body, schema: {
          type: :object,
          properties: { name: { type: :string } }, }
        let(:academic_timeline) { create(:academic_timeline) }
        let(:id) { academic_timeline.id }
        response(200, 'updated by registrar') do
          let(:current_user) { registrar }
          let(:payload) do
            { payload: { name: 'Updated Timeline Name' } }
          end

          schema type: :object,
                 properties: {
                   payload: {
                     type: :object,
                     properties: {
                       record: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           name: { type: :string },
                           start_date: { type: :string, format: :date },
                           end_date: { type: :string, format: :date },
                           timeline_type: { type: :string },
                           created_at: { type: :string, format: :datetime },
                           updated_at: { type: :string, format: :datetime }, },
                         required: %w[id name start_date end_date timeline_type created_at updated_at], } },
                     required: %w[record], },
                   meta: {
                     type: :object,
                     properties: {
                       pagination: { type: :object } }, }, },
                 required: %w[payload meta]

          run_test!
          response(403, 'forbidden for dean') do
            let(:current_user) { dean }
            let(:payload) do
              { payload: { name: 'Updated Timeline Name' } }
            end
            run_test!
          end
        end
      end

      delete('Delete an academic timeline') do
        tags 'Academic Timelines'

        response(200, 'deleted by registrar') do
          let(:current_user) { registrar }
          let(:id) { create(:academic_timeline).id }

          run_test!
        end

        response(403, 'forbidden for dean') do
          let(:current_user) { dean }
          let(:id) { create(:academic_timeline).id }

          run_test!
        end

        response(403, 'forbidden for random user') do
          let(:current_user) { build(:user) }
          let(:id) { create(:academic_timeline).id }

          run_test!
        end

        response(401, 'unauthenticated') do
          let(:current_user) { nil }
          let(:id) { create(:academic_timeline).id }

          run_test!
        end

        response(404, 'not found') do
          let(:current_user) { registrar }
          let(:id) { 'invalid' }

          run_test!
        end
      end
    end
  end
end
