#!/bin/env ruby
# encoding: utf-8

require 'net/http'
require 'json'

file = File.open("data/raiders.txt", "r")
characters = file.read.split("\n")
file.close

characters.each do |char|
  puts char
  site = 'us.battle.net'
  resource = "/api/wow/character/greymane/#{char}?fields=items"
  json = JSON.parse(Net::HTTP.get(site, resource))
  File.open("data/#{char}.json", 'w') {|f| f.write(JSON.pretty_generate(json))}
end