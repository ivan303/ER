Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations",
                    # passwords: "users/passwords",
                    sessions: "users/sessions" }
  resources :users, only: [:show, :index, :update]
  resources :schedules, only: [:show, :index, :destroy, :create]
  # resources :appointments, only: [:index]

  # map.resources :appointments, :collection => { :update_calendar => :get } 
  resources :appointments, only: [:index] do
    get 'update_calendar', :on => :collection
  end


  # as :user do
  #   get 'users/profile', :to => 'users/registrations#edit', :as => :user_root
  # end

  # match 'user_root' => 'users#show'
  # get 'users#show', :as => :user_root
  root 'users#index'

end
