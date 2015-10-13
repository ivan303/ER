Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations",
                    # passwords: "users/passwords",
                    sessions: "users/sessions" }
  resources :users, only: [:show, :index, :update]
  resources :schedules, only: [:show, :index, :destroy, :create]
  resources :clinics, only: [:index, :destroy, :create]
  resources :doctors, only: [:index, :update, :destroy, :create]
  resources :patients, only: [:index, :update, :destroy]
  resources :employments, only: [:index, :destroy, :create]
  # resources :appointments, only: [:index]

  # map.resources :appointments, :collection => { :update_calendar => :get } 
  resources :appointments, only: [:index, :create, :destroy] do
    get 'update_calendar', :on => :collection
    post 'create_appointment_in_clinic', :on => :collection
    post 'create_appointment_at_doctor', :on => :collection
    put 'confirm', :on => :member
  end


  # as :user do
  #   get 'users/profile', :to => 'users/registrations#edit', :as => :user_root
  # end

  # match 'user_root' => 'users#show'
  # get 'users#show', :as => :user_root
  root 'users#show'

end
