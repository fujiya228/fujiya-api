Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :location_scores, only: %i[show]
    end
  end
end
