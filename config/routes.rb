Academic::Engine::Engine.routes.draw do
  mount Rswag::Ui::Engine => '/academic-api-docs'
  mount Rswag::Api::Engine => '/academic-api-docs'
  resources :program_offerings
  resources :programs
  resources :academic_timelines
  resources :intakes
end
