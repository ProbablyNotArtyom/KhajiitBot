#!/usr/bin/env ruby
#
# MIT License
#
# Copyright (c) 2021 Carson Herrington
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

#====================================================================================================
# KhajiitBot - NotArtyom - 2021
# ----------------------------------------
# A Discord bot written in ruby
#====================================================================================================

ENV['SSL_CERT_FILE'] = '/etc/ssl/certs/cacert.pem'
# Workaround for OpenSSL's broken ass certs

require 'discordrb'
require 'openssl'
require 'json'
require 'resolv-replace'
require 'net/http'
require 'net/https'
require 'tempfile'
require 'mini_magick'
require 'rutui'
require 'io/console'

#=========================================== Constants ==============================================

CLIENT_ID = File.read("./ext/sys/client").chomp		# KhajiitBot Client ID (put it here, this one isn't valid!)
TOKEN = File.read("./ext/sys/token").chomp			# shh secrets (Put your token in this file too...)
E621_KEY = File.read("./ext/sys/e621").chomp		# ssh more secrets (Put your e621 account's API key here)

DEBUG = false										# Enable to display debug info for commands that write to the debug stream

EMBED_MSG_COLOR = 0xf5367c							# Sets the default embed color used by bot embeds
EMBED_ERROR_COLOR = 0xe62f2f						# Sets the embed color used for error messages

#============================================= Globals ==============================================

$boottime = 0										# Holds the time of the last boot

#=============================================== Main ===============================================

$bot = Discordrb::Commands::CommandBot.new(
	token: TOKEN,
	client_id: CLIENT_ID,
	prefix: ['k.', 'K.'],
	fancy_log: true,
	ignore_bots: false,
	advanced_functionality: false,
	intents: [
		:servers,
 		:server_members,
 		:server_bans,
 		:server_emojis,
 		:server_integrations,
 		:server_webhooks,
 		:server_invites,
 		:server_voice_states,
 		:server_presences,
 		:server_messages,
 		:server_message_reactions,
 		:server_message_typing,
 		:direct_messages,
 		:direct_message_reactions,
 		:direct_message_typing
	]
)

$bot.should_parse_self = true

require_relative 'Helpers.rb'				# Abstractions
require_relative 'Commands.rb'				# Bot commands
require_relative 'Image.rb'					# Image manipulation
require_relative 'Cmdline.rb'				# Internal shell

PList = Permit.new()												# Create a permit list
Config = Setting.new()												# Set up persistence class

Blacklist_E926 = E621_blacklist.new(Config, "e926_blacklist")		# Set up e926 blacklist handler
Blacklist_E621 = E621_blacklist.new(Config, "e621_blacklist")		# Set up e621 blacklist handler

$boottime = Time.new							# Save to time the bot was started. used in uptime
puts('Current time: ' + $boottime.ctime)
puts('KhajiitBot Starting...')

#====================================================================================================

$bot.message(with_text: "k.hydrate", in: 569337203248070656) do |event|
	target = "<@208140167536574464>"							# Parse the target name and get back a formatted ID
	line = rand(IO.readlines("./ext/hug.action").size-3)+3		# If the target exists then get the number of lines in the string file
	return event.channel.send_embed do |embed|					# Send the embedded action
		embed.description = "**<@342149093117657105>** " + eval(IO.readlines("./ext/hug.action")[line])
		embed.color = EMBED_MSG_COLOR
	end
end

def debug_puts(str)
	puts(str) if (DEBUG == true)
end

#====================================================================================================

$bot.mode = :normal

# Start the bot & run async
$bot.run :async

# Update upon bot finishing its startup
$bot.ready do |event|
	puts("Bot Ready.")
	if (Config.get("game") != nil)
		$bot.game = Config.get("game")
	elsif (Config.get("watching") != nil)
		$bot.watching = Config.get("watching")
	else
		$bot.game = 'k.help'
	end
end

# Notify bot being active
puts('Bot Active')							
puts('Awaiting user activity...')

# If DEBUG is enabled, then hault here instead of starting the CMD shell
while (DEBUG) do; end						

# Startup the TUI interface
Interface = PilotInterface.new(Config)
Signal.trap("SIGWINCH") { Interface.tui_redraw() }	# Redraw TUI when window is resized
Interface.run(Config)

#====================================================================================================
