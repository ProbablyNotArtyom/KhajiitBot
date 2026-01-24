#
# MIT License
#
# Copyright (c) 2026 Carson Herrington
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
# KhajiitBot - NotArtyom - 2026
# ----------------------------------------
# OpenAI commands
#====================================================================================================

require 'openai'

#====================================================================================================

OPENAI_KEY = File.read("./ext/sys/openai").chomp	# OpenAI API key
OpenAI.configure do |config|						# Configure client
	config.access_token = OPENAI_KEY
	config.log_errors = true
end

gpt_client = OpenAI::Client.new

#====================================================================================================

OPENAI_TEMPURATURE = 1.0  		# 0 to 2, higher number means more random
OPENAI_MODEL = "gpt-5-nano"		# Model name

$bot.command(:'ask') do |event, *prompt|
	# Dont let people just flood the bot with requests to waste tokens
	if (OpenAI.rough_token_count(prompt.join(" ")) > 75)
		return event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "stop wasting my tokens headass"
			embed.color = EMBED_ERROR_COLOR
		end
	end

	# Start a thread to send typing indicator heartbeats continuously until we kill it
	indicator_thread = Thread.new do
		loop do
			event.channel.start_typing
			DEBUG_PUTS "sending typing indicator"
			sleep(4)
		end
    end

	# Query the API with the prompt
	response = gpt_client.chat(
		parameters: {
			model: OPENAI_MODEL,
			messages: [{ role: "user", content: "#{prompt.join(" ")}"}],
			temperature: OPENAI_TEMPURATURE,
		}
	)

	indicator_thread.kill	# Stop the typing indicator now that we have a response

	return event.channel.send_embed do |embed|
		embed.description = response.dig("choices", 0, "message", "content")
		embed.color = EMBED_MSG_COLOR
	end
end

#====================================================================================================
