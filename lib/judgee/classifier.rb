# encoding: UTF-8

require "redis"

module Judgee
  class Classifier

    ### Constants ###
    CATEGORIES_KEY  = "judgee:categories"
    CATEGORY_KEY    = "judgee:category"
    ALPHA           = 1.0


    attr_reader :redis

    def initialize(options={})
      @redis = Redis.new(options)
    end


    def train(category, data)
      redis.sadd(CATEGORIES_KEY, category_name(category))
      count_occurance(data).each do |word, word_count|
        redis.hincrby(redis_category_key(category), word, word_count)
      end
      "OK"
    end

    def train_fast(category, data)
      redis.sadd(CATEGORIES_KEY, category_name(category))
      occurances          = count_occurance(data)
      database_occurances = Hash[occurances.keys.zip(redis.hmget(redis_category_key(category), occurances.keys))]
      new_occurances      = occurances.merge(database_occurances) { |key, value_occurance, value_database_occurance| value_occurance.to_i + value_database_occurance.to_i }.to_a.flatten!
      redis.hmset(redis_category_key(category), new_occurances)
      "OK"
    end



    def untrain(category, data)
      count_occurance(data).each do |word, word_count|
        new_count = [(redis.hget(redis_category_key(category), word).to_i - word_count), 0].max
        if new_count > 0
          redis.hset(redis_category_key(category), word, new_count)
        else
          redis.hdel(redis_category_key(category), word)
        end
      end
      "OK"
    end

    def untrain_fast(category, data)
      occurances          = count_occurance(data)
      database_occurances = Hash[occurances.keys.zip(redis.hmget(redis_category_key(category), occurances.keys))]
      untrain_occurances  = database_occurances.merge(occurances) { |key, value_occurance, value_untrain_occurance| value_occurance.to_i - value_untrain_occurance.to_i }
      empty_occurances    = untrain_occurances.select { |key, value| value.to_i <= 0 }
      redis.hmset(redis_category_key(category), untrain_occurances.to_a.flatten!)
      redis.hdel(redis_category_key(category), empty_occurances.keys) unless empty_occurances.empty?
      "OK"
    end



    def classify(data)
      result      = Hash.new(0)
      categories  = redis.smembers(CATEGORIES_KEY)

      categories.each do |category|
        count_occurance(data).each do |word, word_count|
          numerator   = (redis.hget(redis_category_key(category), word).to_i + ALPHA).to_f
          denominator = (categories.map { |category| redis.hget(redis_category_key(category), word).to_i }.inject(0, :+) + (ALPHA * data.length)).to_f
          result[category] += (word_count * Math.log(numerator / denominator)).abs
        end
      end

      result.min_by(&:last).first.to_sym
    end

    def classify_fast(data)
      result      = Hash.new(0)
      categories  = redis.smembers(CATEGORIES_KEY)
      occurances  = count_occurance(data)

      categories.each do |category|
        numerator         = Hash[occurances.keys.zip(redis.hmget(redis_category_key(category), occurances.keys))].inject({}) { |hash, (key, value)| hash[key] = value.to_f + ALPHA; hash }
        denominator       = categories.map { |category| Hash[occurances.keys.zip(redis.hmget(redis_category_key(category), occurances.keys))] }.inject(Hash.new(0)) { |main_hash, sub_hash| main_hash.merge(sub_hash) { |key, value_first, value_second| value_first.to_f + value_second.to_f} }.inject(Hash.new(0)) { |hash, (key, value)| hash[key] = value.to_f + (ALPHA * data.length); hash }
        result[category] += numerator.merge(denominator) { |key, value_numerator, value_denominator| (occurances[key] * Math.log(value_numerator / value_denominator)).abs }.values.inject(0, :+)
      end

      result.min_by(&:last).first.to_sym
    end



    def flushdb(flush_db=false)
      redis.flushdb if flush_db
    end



    def flush_category(category)
      redis.del(redis_category_key(category))
      redis.srem(CATEGORIES_KEY, category_name(category))
    end


    private


    def count_occurance(data='')
      bag_of_words = Hash.new(0)

      data = [data].flatten.map do |word|
        word.to_s.strip
      end.delete_if(&:empty?)

      for word in data
        bag_of_words[word] += 1
      end
      bag_of_words
    rescue
      raise ArgumentError, 'Input must be a single String or an Array of Strings'
    end


    def category_name(category)
      category.to_s.downcase.strip.gsub(/[\s\W]+/,'_').gsub(/_+$/,'')
    end


    def redis_category_key(category)
      "#{CATEGORY_KEY}:#{category_name(category)}"
    end

  end
end
