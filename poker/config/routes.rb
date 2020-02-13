Rails.application.routes.draw do
  get 'welcome/index'
  #get means rails mapsrequests to localhost:3000/welcome/index to the index action

  #created by andrew while learning rails 2/13, see app/controllers/cards_controller.rb
  resources :cards
  #this is a resources method which is used to declare a standard REST resource

  root 'welcome#index'
  #root means rails maps requests to the root (localhost:3000) to the index action

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
