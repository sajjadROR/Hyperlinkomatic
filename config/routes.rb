Rails.application.routes.draw do
  resources :book_marks

  root 'book_marks#index'
end
