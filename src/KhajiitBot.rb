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

$bot.message(in: $cmdChannel) do |event|	# Print out any messages from the current channel
  puts("\r\033[K#{event.message.author.display_name} : #{event.message.content.gsub('\n', "\r\n")}\r\n")
  print ("#{$bot.channel($cmdChannel.to_i).name}>")
  print ($inBuffer)
end

def read_char								# ***BIG BODGE ALERT***
 system "stty raw -echo"					# Here we disable automatic-echo and set our terminal to give us the RAW input data
 return STDIN.getc							# so that we can completely control what gets printed
ensure
 system "stty -raw echo"					# Make sure we set it back to normal on exit
end

#==================================================

$bot.mode = :silent
$bot.run :async								# Start the bot & run async
puts('Bot Active')							# Notify bot being active
puts('Awaiting user activity...')

loop do										# MAIN COMMAND PROMPT LOOP
	print ("#{$bot.channel($cmdChannel.to_i).name}>")					# Print prompt
	$inBuffer = ""								# Get the user input and turn it into a word array
	index = 0
	until $inBuffer.end_with?("\r")				# MAIN CHARACTER INPUT LOOP
		char = read_char							# Get a char from the input
		if char == ("\u007F")						# If its a DELETE, then handle it
			unless index == 0 							# Ignore the DELETE if we're at index 0
				print "\033[1D \033[1D"					# Remove the last char from the prompt
				$inBuffer[index-1] = ""					# Remove it from the buffer
				index -= 1								# Decrease index
			end
		else										# Anything else
			putc char									# Output the char to the prompt
			$inBuffer << char							# Tag it onto the end of the buffer
			index += 1									# Increase index
		end
	end
	cIn = $inBuffer.split(" ")
	unless cIn[0] == nil						# Ignore everything if the input is nil
		if cIn[0].downcase == "go"						# GO command
			chan = cIn.delete_at(1)							# Get the channel from the user input
			if chan != nil && chan.length == 18				# Make sure it's the right length
				$cmdChannel = chan.to_i  					# Set the current channel
				Config.save("channel", $cmdChannel)			# Save the current channel across runs
			else printf("\033[KInvalid Channel") end		# Notify channel fuckery
		elsif cIn[0].downcase == "exit"					# EXIT command
			$bot.stop()										# Stop the bot
			exit											# Exit
		elsif cIn[0].downcase == "status"				# STATUS command
			stat = cIn.delete_at(1)							# Delete the command
			if stat == "online"
				$bot.online									# Set status as online
				printf ("\033[KKhajiitBot now online")
			elsif stat == "idle"
				$bot.idle									# Set status as idle
				printf("\033[KKhajiitBot now idle")
			elsif stat == "invisible"
				$bot.invisible								# Set status as invisible
				printf("\033[KKhajiitBot now invisible")
			else printf("\033[KInvalid status") end
		elsif cIn[0].downcase == "play"					# PLAY command
			cIn.delete_at(0)								# Remove the command
			msg = cIn.join(" ")								# Get desired string
			$bot.game=(msg)									# Set game status
			Config.save("game", msg)						# Save the current game across runs
			Config.save("watching", nil)
		elsif cIn[0].downcase == "watch"				# WATCH command
			cIn.delete_at(0)								# Remove the command
			msg = cIn.join(" ")								# Get desired string
			$bot.watching=(msg)								# Set watching status
			Config.save("watching", msg)					# Save the current vid name across runs
			Config.save("game", nil)
		elsif $cmdChannel == "KhajiitBot"					# Sanity Check
			printf("\033[KYou must select a valid channel!")# Fault if no channel has been selected
		elsif cIn[0].downcase == "say"					# SAY command
			cIn.delete_at(0)								# Delete the command from the user input
			msg = cIn.join(" ")								# Joint the rest of the input, as it is our message
			printf("\033[KKhajiitBot : #{msg}")				# Print the message to the CMD prompt
            $bot.send_message($cmdChannel, msg)				# Send the message
		elsif cIn[0].downcase == "embed"				# EMBED command
			cIn.delete_at(0)								# Delete the command from the user input
			msg = cIn.join(" ")								# Joint the rest of the input, as it is our message
			$bot.send_message($cmdChannel, nil, false, {"description" => msg, "color" => 0xa21a5d})
		elsif cIn[0].downcase == "rm"					# RM command
			msg = $bot.channel($cmdChannel).history(10).collect { |x| x.author.id }		# Make id table
			$i = 0
			until msg[$i] == CLIENT_ID.to_i || $i == 11; $i += 1 end					# Scan for Bot's ID
			unless $i == 11; $bot.channel($cmdChannel).history(10)[$i].delete end		# Delete message if its ours
		elsif cIn[0].downcase == "leave"				# LEAVE command
			id = cIn.delete_at(1).to_i						# Delete the channel ID into id
			$bot.servers.each_value {|x| 					# Scan the list of servers to find a match, then leave that server
				if x.id == id
					printf("\033[KLeft #{x.name}")
					x.leave
					break 2
				end
			}
		elsif cIn[0].downcase == "dm"					# DM command
			cIn.delete_at(0)								# Delete the command from the user input
			uid = cIn.delete_at(0)							# get the recipient uid
			msg = cIn.join(" ")								# Joint the rest of the input, as it is our message
			$bot.user(uid.to_i).pm(msg)
		elsif cIn[0].downcase == "uid"					# UID command
			cIn.delete_at(0)								# Remove the command
			uname = Parser.get_user(cIn.join(" "))			# Get the username
			if uname != nil
				printf("%s", uname.id.to_s)
			else
				printf("\033[KInvalid User")
			end
		elsif cIn[0].downcase == "sid"					# SID command
			cIn.delete_at(0)								# Remove the command
			sname = Parser.get_server(cIn.join(" "))			# Get the server name
			if sname != nil
				printf("%s", sname.id.to_s)
			else
				printf("\033[KInvalid Server")
			end
		elsif cIn[0].downcase == "list"					# LIST command
			servers = $bot.servers.each_value {|x| 			# For each server, print out its name and ID
				printf("\n%s : %d", x.name, x.id)
			}
		else printf("\033[KInvalid Command") 			# Notify invalid command input
		end
		puts("")
	end
end

#==================================================
