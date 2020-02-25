Rails.application.routes.draw do

  get 'welcome/index'
  #get means rails mapsrequests to localhost:3000/welcome/index to the index action
  root 'welcome#index'
  #root means rails maps requests to the root (localhost:3000) to the index action

  #extra webpages not associated with resources
  get 'welcome/tutorial'

  #created by andrew while learning rails 2/13, see app/controllers/cards_controller.rb
  resources :games
  #resources method, used to declare a standard REST resource, provides many routes
  resources :cards
  resources :users
  resources :players

end
