
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

#===================Constants======================

CLIENT_ID = 023984523094877234			# KhajiitBot Client ID (put it here, this one isn't valid!)
token = File.read "./ext/token"			# shh secrets (Put your token in this file too...)

#=====================Globals======================

$boottime = 0							# Holds the time of the last boot

#======================Main========================

$bot = Discordrb::Commands::CommandBot.new token: token , client_id: CLIENT_ID , prefix: ['k.', 'K.'], ignore_bots: false

require_relative 'Security.rb'			# Abstractions
require_relative 'Commands.rb'			# Bot commands

$boottime = Time.now.utc				# save to time the bot was started. used of uptime
puts('Current time: ' + $boottime.inspect)
puts('KhajiitBot Starting...')

$bot.ready do							
	$bot.game = 'k.help'				# Set the "playing" text to the help command
end

#==================================================

trap('INT') do							# Graceful violent exit
	exit
end

#==================================================

PList = Permit.new()					# Create a permit list
BList = Blacklist.new()					# Create a blacklist
NList = NSFW.new()						# Create a NSFW channels list
Parser = Parse.new()					# Setup ID parsing class

puts('Bot Active')						# Notify bot being active
puts('Awaiting user activity...')		
$bot.run :async							# Start the bot & run async

loop do									# MAIN COMMAND PROMPT LOOP
	print ('KhajiitBot>')					# Print prompt
	cIn = gets.split(" ")					# Get the user input and turn it into a word array
	unless cIn[0] == nil						# If the prompt is empty ignore everything
		if cIn[0].downcase == "say"					# SAY command
			chan = cIn.delete_at(1)						# Delete the channel ID from the input and put the ID into a buffer
			if chan != nil && chan.length == 18 		# Make sure the next argument is the right length to be a channel ID
				cIn.delete_at(0)						# Delete the command from the user input
				msg = cIn.join(" ")						# Joint the rest of the input, as it is our message
				puts msg								# Print the message to the CMD prompt
				$bot.send_message(chan.to_i, msg)		# Send the message
			else puts("Invalid Channel") end			# Notify invalid channel input
		elsif cIn[0].downcase == "exit"				# EXIT command
			exit										# Exit
		elsif cIn[0].downcase == "embed"			#  EMBED Command
			chan = cIn.delete_at(1)						# Delete the channel ID from the input and put the ID into a buffer
			if chan != nil && chan.length == 18 		# Make sure the next argument is the right length to be a channel ID
				cIn.delete_at(0)						# Delete the command from the user input
				msg = cIn.join(" ")						# Joint the rest of the input, as it is our message
				$bot.send_message(chan.to_i, nil, false, {"description" => msg, "color" => 0xa21a5d})
			else puts("Invalid Channel") end			# Notify invalid channel input
		else puts("Invalid Command\n") 				# Notify invalid command input
		end
	end
end

#==================================================

