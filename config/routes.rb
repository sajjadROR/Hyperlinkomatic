Rails.application.routes.draw do
  resources :book_marks

  root 'book_marks#index'

  namespace :api do
    namespace :v1 do
      resources :book_marks
    end
  end

end
