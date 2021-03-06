# Judgee

A simple Bayesian Classifier with additive smoothing built in.
The primary focus of judgee lies on performance and a minimal but flexible feature set.
So it's up to you to do stemming, text analysis, etc.


## Backed by Redis

[Redis](http://redis.io/) is an open source, BSD licensed, advanced key-value store, which is often referred to as a data structure server.
It supports strings, hashes, lists, sets, sorted sets and offers an incredible performance.


## Installation

	gem install judgee


## Getting started

	# Require Judgee
	require "judgee"
  
	# Create an instance of Judgee.
	# Judgee assumes that your Redis instance is running on localhost at port 6379.
	judgee = Judgee::Classifier.new

	# Is your Redis instance running on a host in your network, simply pass your options
	judgee = Judgee::Classifier.new(:host => "10.0.1.1", :port => 6380)

	# Judgee also supports Unix sockets
	judgee = Judgee::Classifier.new(:path => "/tmp/redis.sock")


	# Now you can train the classifier
	judgee.train(:spam, ["bad", "worse", "stupid", "idiotic"])
	judgee.train(:ham, ["good", "better", "best", "lovely"])

	# After training, classify your text sample
	judgee.classify(["good", "better", "best", "worse"]) # => :ham


	# Want to untrain some words?
	judgee.untrain(:spam, ["bad", "worse"])


## Information on Performance 

If you have a look at the source code, you might stumble upon two different method namings.
There are two methods for training *(train, train_fast)*, two methods for untraining *(untrain, untrain_fast)* and two methods for classification *(classify, classify_fast)*.
The difference is quite simple. As the name suggests, all methods with the suffix *'_fast'* are (really) faster (3x to 10x) in processing the data, but virtually unreadable.

So use the *'_fast'* methods if you need performance, e.g. in you production environment and the 'slow' methods just for learning purposes or small data.

## Using the *_fast* methods

	# Now you can train the classifier
	judgee.train_fast(:spam, ["bad", "worse", "stupid", "idiotic"])
	judgee.train_fast(:ham, ["good", "better", "best", "lovely"])

	# After training, classify your text sample
	judgee.classify_fast(["good", "better", "best", "worse"]) # => :ham


	# Want to untrain some words?
	judgee.untrain_fast(:spam, ["bad", "worse"])