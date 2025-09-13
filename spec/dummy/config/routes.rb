Rails.application.routes.draw do
  mount Academic::Engine::Engine => '/academics'
end
