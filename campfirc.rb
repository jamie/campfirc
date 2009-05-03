require 'rubygems'
require 'yaml'
gem 'ichverstehe-isaac', '>= 0.2.5'; require 'isaac'
gem 'tinder', '>= 1.2.0'; require 'tinder'

CONFIG = YAML.load(File.read('config.yml'))


# Campfire
campfire = Tinder::Campfire.new(CONFIG['campfire']['subdomain'])
campfire.login(CONFIG['campfire']['email'], CONFIG['campfire']['password'])

$rooms = {}
campfire.rooms.select{|r| r.name =~ /#/ }.each do |room|
  next unless room.name =~ Regexp.new(CONFIG['irc']['server'])
  
  channel = room.name.sub(CONFIG['irc']['server'], '')
  $rooms[channel] = room
  
  room.join(true)
  Thread.new {
    room.listen { |m|
      if m[:person] == CONFIG['campfire']['owner']
        Isaac.bot.msg channel, m[:message]
      end
    }
  }
end
trap("SIGINT") do
  $rooms.values.each do |room| room.leave end
  exit(0)
end


# IRC
configure do |c|
  c.nick = CONFIG['irc']['nick']
  c.server = CONFIG['irc']['server']
  c.port = CONFIG['irc']['port']
end

on :connect do
  join *$rooms.keys
end

on :channel do
  msg = message.chomp
  $rooms[channel].speak "<#{nick}> #{msg}"
end

Isaac.bot.start
