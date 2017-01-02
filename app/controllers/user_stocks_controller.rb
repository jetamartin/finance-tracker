class UserStocksController < ApplicationController
  before_action :set_user_stock, only: [:show, :edit, :update, :destroy]

  # GET /user_stocks
  # GET /user_stocks.json
  def index
    @user_stocks = UserStock.all
  end

  # GET /user_stocks/1
  # GET /user_stocks/1.json
  def show
  end

  # GET /user_stocks/new
  def new
    @user_stock = UserStock.new
  end

  # GET /user_stocks/1/edit
  def edit
  end

  # POST /user_stocks
  # POST /user_stocks.json
  def create
    # debugger
    # If no stock_id then it was not previously in DB and we'll need to create a
    # new entry in the DB
    if params[:stock_id].present?
     @user_stock = UserStock.new(stock_id: params[:stock_id], user: current_user)
    else # Check DB to see if stock already in DB -- redundant check
      stock = Stock.find_by_ticker(params[:stock_ticker])
      if stock # Stock found in DB set up Association with this stock_id
        @user_stock = UserStock.new(user: current_user, stock: stock)
      else # Stock not found in DB so look it up via external service
        stock = Stock.new_from_lookup(params[:stock_ticker])
        if stock.save #stock was found and saved to DB.
          #Note: Through magic of Rails it knows to use user_id & stock_id even though we reference
          # entire stock and user object
          @user_stock = UserStock.new(user: current_user, stock: stock)
        else #Stock could not be found by ticker provided..set flash message
          @user_stock = nil
          flash[:error] = "Stock is not available"
        end
      end
    end
   

    respond_to do |format|
      if @user_stock.save
        format.html { redirect_to my_portfolio_path, notice: "Stock #{@user_stock.stock.ticker} was successfully added." }
        format.json { render :show, status: :created, location: @user_stock }
      else
        format.html { render :new }
        format.json { render json: @user_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_stocks/1
  # PATCH/PUT /user_stocks/1.json
  def update
    respond_to do |format|
      if @user_stock.update(user_stock_params)
        format.html { redirect_to @user_stock, notice: 'User stock was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_stock }
      else
        format.html { render :edit }
        format.json { render json: @user_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_stocks/1
  # DELETE /user_stocks/1.json
  def destroy
    # debugger
    @user_stock.destroy
    respond_to do |format|
      format.html { redirect_to my_portfolio_path, notice: 'Stock was successfully removed from your portfolio' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_stock
      # debugger
      @user_stock = UserStock.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_stock_params
      params.require(:user_stock).permit(:user_id, :stock_id)
    end
end
