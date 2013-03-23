# encoding: UTF-8

require 'judgee'
require 'redis'

describe Judgee::Classifier do  
  
  CATEGORIES_KEY  = "judgee:categories"
  CATEGORY_KEY    = "judgee:category"
  
  before :each do
    @judgee         = Judgee::Classifier.new
    @redis          = Redis.new
    @redis.flushdb
    @spam_category  = :spam_spec
    @ham_category   = :ham_spec
    @spam_data      = %w(money rich quick big viagra penis)
    @ham_data       = %w(mail google gmail maps ruby)
    @judgee.flush_category(@spam_category)
    @judgee.flush_category(@ham_category)
  end
  
  describe "training" do
    it "should add category to 'judgee:categories' set" do
      @judgee.train(@ham_category, @ham_data)
      @judgee.train(@spam_category, @spam_data)
      categories = @redis.smembers(CATEGORIES_KEY)
      categories.length.should eq 2
    end
  end
  
  # TODO
  
end