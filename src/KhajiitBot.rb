
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

CLIENT_ID = File.read "./ext/sys/client"	# KhajiitBot Client ID (put it here, this one isn't valid!)
token = File.read "./ext/sys/token"			# shh secrets (Put your token in this file too...)

#=====================Globals======================

$boottime = 0								# Holds the time of the last boot

#======================Main========================

$bot = Discordrb::Commands::CommandBot.new token: token , client_id: CLIENT_ID , prefix: ['k.', 'K.'], ignore_bots: false

require_relative 'Security.rb'				# Abstractions
require_relative 'Commands.rb'				# Bot commands

PList = Permit.new()						# Create a permit list
Parser = Parse.new()						# Setup ID parsing class
Config = Setting.new()						# Set up persistence class

$boottime = Time.now.utc					# save to time the bot was started. used of uptime
puts('Current time: ' + $boottime.inspect)
puts('KhajiitBot Starting...')

$bot.ready do							
	if Config.get("game") == nil then $bot.game = 'k.help'		# Set the "playing" text to the help command
	else 
		$bot.game = Config.get("game") 
	end
end

#==================================================

trap('INT') do								# Graceful violent exit
	exit
end

#==================================================

$cmdChannel = Config.get("channel")			# Reload the last active channel
$inBuffer = ""

$bot.message(in: $cmdChannel) do |event|
  puts("\r\033[K#{event.message.author.display_name} : #{event.message.content}\r\n")
  print ("#{$cmdChannel}>")
  print ($inBuffer)
end

def read_char
 system "stty raw -echo"
 char = STDIN.getc
 putc char
 return char
ensure
 system "stty -raw echo"
end

#==================================================

$bot.run :async								# Start the bot & run async
puts('Bot Active')							# Notify bot being active
puts('Awaiting user activity...')		

loop do										# MAIN COMMAND PROMPT LOOP
	print ("#{$cmdChannel}>")					# Print prompt
	$inBuffer = ""								# Get the user input and turn it into a word array
	index = 0
	until $inBuffer.end_with?("\r")
		$inBuffer << read_char
		index += 1
	end
	cIn = $inBuffer.split(" ")
	unless cIn[0] == nil						# Ignore everything if the input is nil	
		if cIn[0].downcase == "go"					# GO command
			chan = cIn.delete_at(1)							# Get the channel from the user input
			if chan != nil && chan.length == 18				# Make sure it's the right length
				$cmdChannel = chan.to_i  					# Set the current channel
				Config.save("channel", $cmdChannel)			# Save the current channel across runs
				puts "\r\n"
			else puts("\r\033[KInvalid Channel\r\n") end				# Notify channel fuckery
		elsif cIn[0].downcase == "exit"				# EXIT command
			exit											# Exit
		elsif cIn[0].downcase == "status"			# STATUS command
			stat = cIn.delete_at(1)							# Delete the command
			if stat == "online"
				$bot.online									# Set status as online
				puts "\r\033[KKhajiitBot now online\r\n"
			elsif stat == "idle"	
				$bot.idle									# Set status as idle
				puts "\r\033[KKhajiitBot now idle\r\n"
			elsif stat == "invisible"
				$bot.invisible								# Set status as invisible
				puts "\r\033[KKhajiitBot now invisible\r\n"
			else puts("\r\033[KInvalid status\r\n") end
		elsif cIn[0].downcase == "play"				# PLAY command
			game = cIn.delete_at(0)							# Remove the command
			msg = cIn.join(" ")								# Get desired string
			$bot.game=(msg)									# Set game status
			Config.save("game", msg)						# Save the current game across runs
		elsif $cmdChannel == "KhajiitBot"			# Sanity Check
			puts("\r\033[KYou must select a valid channel!\r\n")		# Fault if no channel has been selected
		elsif cIn[0].downcase == "say"				# SAY command	
			cIn.delete_at(0)								# Delete the command from the user input
			msg = cIn.join(" ")								# Joint the rest of the input, as it is our message
			puts "\r\033[KKhajiitBot : #{msg}\r\n"										# Print the message to the CMD prompt
			
            $bot.send_message($cmdChannel, msg)				# Send the message	
		elsif cIn[0].downcase == "embed"			# EMBED Command	
			cIn.delete_at(0)								# Delete the command from the user input
			msg = cIn.join(" ")								# Joint the rest of the input, as it is our message
			$bot.send_message($cmdChannel, nil, false, {"description" => msg, "color" => 0xa21a5d})
		elsif cIn[0].downcase == "rm"				# RM command	
			msg = $bot.channel($cmdChannel).history(10).collect { |x| x.author.id }		# Make id table
			$i = 0
			until msg[$i] == CLIENT_ID.to_i || $i == 11; $i += 1 end					# Scan for Bot's ID
			unless $i == 11; $bot.channel($cmdChannel).history(10)[$i].delete end		# Delete message if its ours
		else puts("\r\033[KInvalid Command\r\n") 						# Notify invalid command input
		end
	end
end

#==================================================
