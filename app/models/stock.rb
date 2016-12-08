class Stock < ActiveRecord::Base
  has_many :user_stocks
  has_many :users, through: :user_stocks
  # Class method to look up stock from Stock DB and return Stock object
  def self.find_by_ticker(ticker_symbol)
    where(ticker: ticker_symbol).first
  end
  
  # Class method to look up stock info from external source (GEM stock_quote)
  def self.new_from_lookup(ticker_symbol)
    looked_up_stock = StockQuote::Stock.quote(ticker_symbol)
    # if no stock found with given symbol return nil
    return nil unless looked_up_stock.name
    # If stock found then create and build stock object to be returned
    new_stock = new(ticker: looked_up_stock.symbol, name: looked_up_stock.name)
    new_stock.last_price = new_stock.price
    new_stock
  end
  
  # Price returned depends on whether market still open or already closed
  def price
    # if markets aren't closed there will not be a closing price yet.
    closing_price = StockQuote::Stock.quote(ticker).close
    return "#{closing_price} (Closing)" if closing_price
    
    # Opening price should be available but if not just return 'Unavailable'
    opening_price = StockQuote::Stock.quote(ticker).open
    return "#{opening_price} (Opening)" if opening_price
    
    'Unavailable'
  end
  
  
end
