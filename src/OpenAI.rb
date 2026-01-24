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
gpt_client = OpenAI::Client.new(
	api_key: OPENAI_KEY
)

#====================================================================================================

OPENAI_TEMPERATURE = 1.0  			# 0 to 2, higher number means more random
OPENAI_TEXT_MODEL = "gpt-5-nano"	# Text model name
OPENAI_TEXT_PROMPT_MAX = 75			# Maximum input words for text prompts
OPENAI_IMAGE_MODEL = "dalle-e-2"	# Image model name
OPENAI_IMAGE_PROMPT_MAX = 150		# Maximum input words for image prompts

# ASK Command
$bot.command(:'ask') do |event, *prompt|
	# Dont let people just flood the bot with requests to waste tokens
	if (prompt.size > OPENAI_TEXT_PROMPT_MAX)
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
	response = gpt_client.chat.completions.create(
		model: OPENAI_TEXT_MODEL,
		messages: [{ role: "user", content: prompt.join(" ")}],
		temperature: OPENAI_TEMPERATURE,
		user: event.message.author.id.to_s
	)

	indicator_thread.kill	# Stop the typing indicator now that we have a response

	return event.channel.send_embed do |embed|
		embed.description = response.choices[0].message.content[0..4095]	# Make sure response will fit into a discord message
		embed.color = EMBED_MSG_COLOR
	end
end

# DALLE Command
$bot.command(:'dalle') do |event, *prompt|
	# Dont let people just flood the bot with requests to waste tokens
	if (prompt.size > OPENAI_IMAGE_PROMPT_MAX)
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
	response = gpt_client.images.generate(
		prompt: prompt.join(" "),
		model: "dall-e-2",
		size: "1024x1024"
	)

	indicator_thread.kill	# Stop the typing indicator now that we have a response

	return event.channel.send_embed do |embed|
		embed.title = "\"#{prompt.join(" ")}\""
		embed.image = Discordrb::Webhooks::EmbedImage.new(url: response.data[0].url)
		embed.color = EMBED_MSG_COLOR
	end
end

#====================================================================================================
