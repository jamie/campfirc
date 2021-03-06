require 'yaml'
require 'rubygems'
require 'htmlentities'
gem 'ichverstehe-isaac', '>= 0.2.5'; require 'isaac'
gem 'tinder', '>= 1.2.0'; require 'tinder'

working_dir = File.expand_path(File.dirname(__FILE__))
CONFIG = YAML.load(File.read(File.join(working_dir, 'config.yml')))
File.open(File.join(working_dir, 'campfirc.pid'), 'w') do |f|
  f  << Process.pid
end

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
        m[:message].gsub!(/\\u0026/, '&')
        puts "CF:  #{channel} #{m[:message].inspect}"
        # "has left the room " has a trailing space, wtf
        next if m[:message] =~ /^has (entered|left) the room ?$/
        Isaac.bot.msg channel, HTMLEntities.new.decode(m[:message])
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
  puts "IRC: #{channel} <#{nick}> #{msg.inspect}"
  $rooms[channel].speak "<#{nick}> #{msg}"
end

Isaac.bot.start
