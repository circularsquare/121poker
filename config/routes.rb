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

  post 'games/add_ai', to: 'games#add_ai'
  post 'games/add_player', to: 'games#add_player'
  post 'games/action', to: 'games#action' #bet, fold, check, etc.
  post 'games/move_card', to: 'games#move_card'
  post 'games/deal', to: 'games#deal'
  post 'games/set_round', to: 'games#set_round'
  post 'games/leave_game', to: 'games#leave_game'
  post 'games/start_game', to: 'games#start_game'
  post 'games/ai_play', to: 'games#ai_play'

  #created by andrew while learning rails 2/13, see app/controllers/cards_controller.rb
  resources :games
  resources :cards
  resources :users
  resources :players
  #resources method, used to declare a standard REST resource, provides many routes

end
