class Api::V1::BookMarksController < ApplicationController

  before_filter :authentication

  def index
    p '======================= Index'
    @book_marks = BookMark.all
    render json: @book_marks
  end

  def create

  end


  private

    def authentication
      if request.headers['key'] == 'https://github.com/sajjadmurtaza49-jhdjkf874324b3248b4sdf'
        p '======================= Authentication Pass.'
        true
      else
        p '======================= Authentication failed.'
        render json: 'Authentication failed.'
      end
    end

end