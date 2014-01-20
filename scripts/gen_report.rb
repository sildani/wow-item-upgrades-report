#!/usr/bin/env ruby
# encoding: utf-8

require 'json'

guild = ARGV[0]
if (!guild)
  abort('Usage: gen_report.rb <guild>')
end

file = File.open("data/#{guild}_members.json", "r")
json = JSON.parse(file.read)
file.close
characters = {}
json['members'].each do |char|
  charRank = char['rank']
  if (charRank <= 6 && charRank != 2)
    charName = char['character']['name']
    file = File.open("data/#{charName}.json", "r")
    charJson = JSON.parse(file.read)
    file.close
    characters[charName] = {
      'name' => charName,
      'rank' => charRank,
      'json' => charJson
    }
  end
end

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

data[lineNum] = ['','Class','Spec','Rank','ILvl']
slots.each {|s| data[lineNum] << s.capitalize}

characters.each do |charName, char|
  puts charName
  lineNum += 1
  data[lineNum] = [charName]

  data[lineNum] << 'TBD'
  data[lineNum] << 'TBD'
  data[lineNum] << char['rank']
  data[lineNum] << char['json']['items']['averageItemLevelEquipped']

  slots.each do |slot|
    if (char['json']['items'][slot].nil?)
      data[lineNum] << 'n/a'
    else
      if (char['json']['items'][slot]['tooltipParams']['upgrade'].nil?)
        data[lineNum] << 'pvp'
      else
        currLevel = char['json']['items'][slot]['tooltipParams']['upgrade']['current']
        maxLevel = char['json']['items'][slot]['tooltipParams']['upgrade']['total']
        if (currLevel == maxLevel)
          data[lineNum] << currLevel
        else
          itemLevel = char['json']['items'][slot]['itemLevel']
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

