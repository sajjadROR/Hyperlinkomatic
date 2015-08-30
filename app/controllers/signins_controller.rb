class SigninsController < ApplicationController

  def index
    @signins = Signin.all
  end

  def edit
  end

  def create
    @signin = Signin.new(signin_params)
    @signin.save
  end

  private

    def signin_params
      params.require(:signin).permit(:url)
    end

end
