#!/usr/bin/env ruby
# encoding: utf-8

require 'json'

itemLevels = {
  496 => 'time',
  516 => 'h-scen',
  522 => 'tot',
  528 => 'lfr',
  535 => 'time++',
  540 => 'flex',
  553 => 'reg',
  559 => 'reg wf'
}

characters = []
Dir.foreach('data') do |item|
  next if item == '.' or item == '..' or item.include? '_members' or item == '.gitignore'
  characters << item[0..item.length-6]
end

slots = [
  'head',
  'neck',
  'shoulder',
  'back',
  'chest',
  'wrist',
  'hands',
  'waist',
  'legs',
  'feet',
  'finger1',
  'finger2',
  'trinket1',
  'trinket2',
  'mainHand',
  'offHand'
]

lineNum = 1
data = {}

data[lineNum] = ['']
slots.each {|s| data[1] << s.capitalize}

characters.each do |char|
  puts char
  lineNum += 1
  data[lineNum] = [char]

  file = File.open("data/#{char}.json", "r")
  json = JSON.parse(file.read)
  file.close

  slots.each do |slot|
    if (json['items'][slot].nil?)
      data[lineNum] << 'n/a'
    else
      if (json['items'][slot]['tooltipParams']['upgrade'].nil?)
        data[lineNum] << 'pvp'
      else
        currLevel = json['items'][slot]['tooltipParams']['upgrade']['current']
        maxLevel = json['items'][slot]['tooltipParams']['upgrade']['total']
        if (currLevel == maxLevel)
          data[lineNum] << currLevel
        else
          itemLevel = json['items'][slot]['itemLevel']
          increment = 4
          rawItemLevel = itemLevel - (currLevel * increment)
          if (itemLevels[rawItemLevel].nil?)
            data[lineNum] << "#{currLevel} (unk - #{rawItemLevel})"
          else
            data[lineNum] << "#{currLevel} (#{itemLevels[rawItemLevel]})"
          end
        end
      end
    end
  end
end

buffer = ""
data.each_pair do |key,row|
  row.each do |val|
    buffer << "\"#{val}\","
  end
  buffer << "\n"
end
timestamp = Time.new.strftime("%Y%m%d_%H%M")
File.open("output/report_#{timestamp}.csv", 'w') {|f| f.write(buffer) }

