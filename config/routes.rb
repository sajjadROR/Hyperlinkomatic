Rails.application.routes.draw do
  resources :signins


  root 'signins#index'


end
