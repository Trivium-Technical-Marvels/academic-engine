Academic::Engine::Engine.routes.draw do
  resources :program_offerings
  resources :programs
  resources :academic_timelines
  resources :intakes
end
