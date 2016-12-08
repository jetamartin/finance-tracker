class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :user_stocks
  has_many :stocks, through: :user_stocks
  has_many :friendships
  has_many :friends, through: :friendships
  
  # Note: These methods are called with a User object as a result you can 
  # use user_stocks.count rather than user.user_stocks.count..they are equivalent
  # statements
  
  def full_name
    return "#{first_name} #{last_name}".strip if (first_name || last_name)
    "Anonymous"
  end
  
  def can_add_stock?(ticker_symbol)
    under_stock_limit? && !stock_already_added?(ticker_symbol)
  end
  
  def under_stock_limit?
    # Counts the number of entry for user in user_stocks table..hence giving # of 
    # stocks this user is currently following
    (user_stocks.count < 10) 
  end
    
  def stock_already_added?(ticker_symbol)
    # First check to see stock ticker anywhere in DB and if so get it's id. 
    stock = Stock.find_by_ticker(ticker_symbol) 
    return false unless stock
    # Now that you know the stock's id see if this user is already tracking it?
    user_stocks.where(stock_id: stock.id).exists?
  end
end
