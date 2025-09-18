Academic::Engine::Engine.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  resources :program_offerings
  resources :programs
  resources :academic_timelines
  resources :intakes
end
