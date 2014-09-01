# ARI

[![Gem Version](https://badge.fury.io/rb/asterisk-ari.svg)](http://badge.fury.io/rb/asterisk-ari)
[![Build Status](https://travis-ci.org/t-k/asterisk-ari-ruby.png)](https://travis-ci.org/t-k/asterisk-ari-ruby)

ARI is a Ruby client library for the [Asterisk REST Interface (ARI)](https://wiki.asterisk.org/wiki/pages/viewpage.action?pageId=29395573)

## Installation

Add this line to your application's Gemfile:

    gem 'asterisk-ari', :require => 'ari'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install asterisk-ari

Usage
---
```ruby
require 'ari'
# setup
client = ARI::Client.new({ :host => "localhost", :port => 8088, :username => "username", :password => "password" })
# specify prefix
# client = ARI::Client.new({ :host => "localhost", :port => 8088, :username => "username", :password => "password", :prefix => "asterisk" })

result = client.bridges_create({type: "mixing", bridgeId: "bridge_id", name: "bridge_name"})
# => {"id"=>"bridge_id", "creator"=>"Stasis", "technology"=>"simple_bridge", "bridge_type"=>"mixing", "bridge_class"=>"stasis", "name"=>"bridge_name", "channels"=>[]}

result = client.bridges_get result["id"]
# => {"id"=>"bridge_id", "creator"=>"Stasis", "technology"=>"simple_bridge", "bridge_type"=>"mixing", "bridge_class"=>"stasis", "name"=>"bridge_name", "channels"=>[]}
```
Check http://www.rubydoc.info/github/t-k/asterisk-ari-ruby/master/ARI/Client for other APIs.

Error handling
--
```ruby
begin
  result = client.asterisk_set_global_var
rescue ARI::ServerError => e # handle 5xx request
  puts e.response_body
  puts e.error_info
rescue ARI::APIError => e # handle 4xx request
  puts e.response_body
  # => {"message":"Variable name is required"}
  puts e.error_info
  # {:http_status=>400, :body=>"{\"message\":\"Variable name is required\"}", :data=>{"message"=>"Variable name is required"}}
rescue
end
```

## TODO

* add support for WebSocket APIs [(Events REST API)](https://wiki.asterisk.org/wiki/display/AST/Asterisk+12+Events+REST+API)
* add test