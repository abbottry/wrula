Rails.application.routes.draw do
  resources :site_events, only: [:index, :create], defaults: { format: :js }

  devise_for :users, :controllers => { registrations: "registrations" }

  resources :sites

  get "admin" => "admin#index"
  namespace :admin do
    resources :users
    resources :sites
  end

  root to: "home#index"
end
