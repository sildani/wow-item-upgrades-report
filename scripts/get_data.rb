#!/usr/bin/env ruby
# encoding: utf-8

require 'net/http'
require 'json'

realm = ARGV[0]
guild = ARGV[1]

if (!realm || !guild)
  abort('Usage: get_data.rb <realm> <guild>')
end

site = 'us.battle.net'
resource = '/api/wow/guild/' + realm + '/' + guild + '?fields=members'
json = JSON.parse(Net::HTTP.get(site, resource))
File.open("data/#{guild}_members.json", 'w') {|f| f.write(JSON.pretty_generate(json))}
characters = []
json['members'].each do |char|
  if (char['rank'] <= 6 && char['rank'] != 2)
    characters << {
      'name' => char['character']['name'],
      'rank' => char['rank']
    }
  end
end

characters.sort_by { |char| char['rank'] }.each do |char|
  puts char
  resource = "/api/wow/character/greymane/#{char['name']}?fields=items"
  json = JSON.parse(Net::HTTP.get(site, resource))
  File.open("data/#{char['name']}.json", 'w') {|f| f.write(JSON.pretty_generate(json))}
end