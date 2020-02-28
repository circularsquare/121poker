Rails.application.routes.draw do

  get 'welcome/index'
  #get means rails mapsrequests to localhost:3000/welcome/index to the index action
  root 'welcome#index'
  #root means rails maps requests to the root (localhost:3000) to the index action

  #extra webpages not associated with resources
  get 'welcome/tutorial'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  get 'logout', to: 'sessions#destroy'

  #created by andrew while learning rails 2/13, see app/controllers/cards_controller.rb
  resources :games
  resources :cards
  resources :users
  resources :players
  #resources method, used to declare a standard REST resource, provides many routes

end
