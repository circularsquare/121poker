#this file is created by andrew while learning rails 2/13

class CardsController < ApplicationController
  def new
  end

  def create
    @card = Card.new(card_params) #generates card model from params of form
    @card.save #saves to model in database
    redirect_to @card
  end

  def show
    @card = Card.find(params[:id])
  end

  private
    def card_params
      params.require(:card).permit(:rank, :suit)
    end
end
