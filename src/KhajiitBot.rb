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
require 'resolv-replace'
require 'open-uri'
require 'net/https'
require 'tempfile'
require 'rmagick'
require 'rutui'
require 'io/console'

#===================Constants======================

CLIENT_ID = File.read "./ext/sys/client"	# KhajiitBot Client ID (put it here, this one isn't valid!)
TOKEN = File.read "./ext/sys/token"			# shh secrets (Put your token in this file too...)
E621_KEY = File.read "./ext/sys/e621"		# ssh more secrets (Put your e621 account's API key here)
WORDSAPI_KEY = File.read "./ext/sys/words" 	# WORDSAPI key goes here

#=====================Debug========================

# enable to display debug info for commands that write to the debug stream
DEBUG = false

def debug_loop()
	if (DEBUG == true) then
		while 1 == 1 do
		end
	end
end

def debug_puts(str)
	if (DEBUG == true) then
		puts(str)
	end
end

#=====================Globals======================

$boottime = 0								# Holds the time of the last boot

#======================Main========================

$bot = Discordrb::Commands::CommandBot.new token: TOKEN , client_id: CLIENT_ID , prefix: ['k.', 'K.'], log_mode: :verbose, fancy_log: true, ignore_bots: false, advanced_functionality: false
$bot.should_parse_self = true

require_relative 'Security.rb'					# Abstractions
require_relative 'Commands.rb'					# Bot commands
require_relative 'Image.rb'						# Image manipulation

PList = Permit.new()												# Create a permit list
Parser = Parse.new()												# Setup ID parsing class
Config = Setting.new()												# Set up persistence class
Blacklist_E921 = E621_blacklist.new(Config, "e926_blacklist")		# Set up e926 blacklist handler
Blacklist_E621 = E621_blacklist.new(Config, "e621_blacklist")		# Set up e621 blacklist handler

$boottime = Time.new							# Save to time the bot was started. used of uptime
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

$bot.message(with_text: "k.hydrate", in: 569337203248070656) do |event|
	event.respond("j.duel jbot")
end

#==================================================

$cmdChannel = Config.get("channel")			# Reload the last active channel
$inBuffer = ""

#==================================================

debug_puts("CLIENT_ID: #{CLIENT_ID}")
debug_puts("TOKEN: #{TOKEN}")
debug_puts("E621 KEY: #{E621_KEY}")
debug_puts("WORDSAPI KEY: #{WORDSAPI_KEY}")

if (DEBUG == true)
	$bot.mode = :normal
else
	$bot.mode = :silent
end

$bot.run :async								# Start the bot & run async
puts('Bot Active')							# Notify bot being active
puts('Awaiting user activity...')
debug_loop()

require_relative 'Cmdline.rb'				# Start executing the internal shell

#==================================================
