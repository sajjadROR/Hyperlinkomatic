class BookMarksController < ApplicationController
  before_action :set_book_mark, only: [:destroy, :edit, :update]

  def index
    @book_marks = BookMark.all.order('title asc')
  end


  def create
    @book_mark = BookMark.new(book_mark_params)
    if @book_mark.title.split(/\s+/).last == "+"
      @book_mark.save
    end
  end

  def edit

  end

  def update
    @book_mark.update(book_mark_params)
  end

  def destroy
    if params[:delete] == 'del'
      @book_mark.destroy
    end
  end

  private
    def set_book_mark
      @book_mark = BookMark.find(params[:id])
    end

    def book_mark_params
      params.require(:book_mark).permit(:title, :link_path, :description)
    end

end
