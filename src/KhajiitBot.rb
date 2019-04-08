#!/usr/bin/env ruby
#==================================================
#     KhajiitBot  --  NotArtyom  --  07/24/18
#==================================================
#    KhajiitBot - A Discord bot written w/ ruby
#==================================================
#
# MIT License
#
# Copyright (c) 2018 Carson Herrington
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

ENV['SSL_CERT_FILE'] = '/etc/ssl/certs/cacert.pem'
# Workaround for OpenSSL's broken ass certs

require 'discordrb'
require 'openssl'
require 'json'
require 'open-uri'
require 'net/https'
#require 'rubyhexagon'
require 'rmagick'
require 'rutui'
require 'io/console'

#===================Constants======================

CLIENT_ID = File.read "./ext/sys/client"	# KhajiitBot Client ID (put it here, this one isn't valid!)
token = File.read "./ext/sys/token"			# shh secrets (Put your token in this file too...)

#=====================Globals======================

$boottime = 0								# Holds the time of the last boot

#==================rubyhexagon=====================

#e621_api = E621::API.new()
# GOTTA FIGURE THIS OUT ONE DAY

#======================Main========================

$bot = Discordrb::Commands::CommandBot.new token: token , client_id: CLIENT_ID , prefix: ['k.', 'K.'], ignore_bots: false, advanced_functionality: true
$bot.should_parse_self = true

require_relative 'Security.rb'				# Abstractions
require_relative 'Commands.rb'				# Bot commands
require_relative 'Image.rb'					# Image manipulation

PList = Permit.new()						# Create a permit list
Parser = Parse.new()						# Setup ID parsing class
Config = Setting.new()						# Set up persistence class

$boottime = Time.new						# Save to time the bot was started. used of uptime
puts('Current time: ' + $boottime.ctime)
puts('KhajiitBot Starting...')

$bot.ready do
	if Config.get("game") != nil
		$bot.game = Config.get("game")
	elsif Config.get("watching") != nil
		$bot.watching = Config.get("watching")
	else
		 $bot.game = 'k.help'		# Set the "playing" text to the help command
	end
end

#==================================================

trap('INT') do								# Graceful violent exit
	exit
end

#==================================================

$cmdChannel = Config.get("channel")			# Reload the last active channel
$inBuffer = ""

def read_char								# ***BIG BODGE ALERT***
	state = `stty -g`
	`stty raw -echo -icanon isig`			# Here we disable automatic-echo and set our terminal to give us the RAW input data
	return STDIN.getc						# so that we can completely control what gets printed
ensure
	`stty #{state}`							# Make sure we set it back to normal on exit
end

#==================================================

$bot.mode = :silent
$bot.run :async								# Start the bot & run async
puts('Bot Active')							# Notify bot being active
puts('Awaiting user activity...')

require_relative 'Cmdline.rb'				# Start executing the internal shell

#==================================================
