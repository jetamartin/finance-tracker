class StocksController < ApplicationController
  def search
    # debugger
    if params[:stock]
      @stock = Stock.find_by_ticker(params[:stock]) 
      @stock ||= Stock.new_from_lookup(params[:stock]) 
    end

    if @stock
      # By rendering json and entering app path/search_stocks?stock=GOOG
      # you will see jason object returned and confirm code is working
      # render json: @stock
      render partial:  'lookup'
    else
      render status: :not_found, nothing: true
    end
    
  end
  
end