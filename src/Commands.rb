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
# Command functions
#====================================================================================================

$bot.command :help do |event, *type|			# Help command
	type = type.join(" ")

	return event.send_embed do |embed|				# Send embedded help message
		embed.thumbnail = Discordrb::Webhooks::EmbedImage.new(url: 'http://i.imgur.com/pG3L2RP.png')
		embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'KhajiitBot', url: 'https://discordapp.com/oauth2/authorize?client_id=452660556990644225&scope=bot&permissions=0', icon_url: 'http://i.imgur.com/pG3L2RP.png')
		if (type.empty?)
			embed.add_field(name: 'k.help usage:', value: IO.read("./ext/help/meta").force_encoding("utf-8"))
		else
			if (File.file?("./ext/help/#{type}"))
				embed.add_field(name: "#{type.slice(0, 1).capitalize + type.slice(1..-1)} Commands:", value: IO.read("./ext/help/#{type}").force_encoding("utf-8"))
			else
				embed.add_field(name: 'Error!', value: 'Invalid help type. Please use on option from the list')
			end
		end
		embed.color = EMBED_MSG_COLOR
	end
end

#=============================================== POOLS ==============================================

TRADE_WARES = "This one is displeased with your lack of wares..."				# Error message for when no image is given
TRADE_TYPE = "This one does not think that your wares are of proper type..."	# Error message for when the input file isn't an image

$bot.command(:image) do |event|												# IMAGE command
	numItems = File.read("./ext/meme/max").to_i									# Get the current image count
	output = Dir.glob("./ext/meme/" + rand(numItems + 1).to_s + ".*")			# Pick a random image
	event.attach_file(File.open(output[0], 'r'))								# Return the randomly chosen image
end

$bot.command(:arouse) do |event|											# AROUSE Command
	return nil if (require_nsfw(event)) 										# Make sure the channel is marked as NSFW

	numItems = File.read("./ext/lewd/max").to_i									# Get the current image count
	output = Dir.glob("./ext/lewd/" + rand(numItems + 1).to_s + ".*")			# Pick a random image
	event.attach_file(File.open(output[0], 'r'))								# Return the randomly chosen image
end

$bot.command(:trade) do |event|												# TRADE Command
	return TRADE_WARES if (event.message.attachments.empty?)					# If there are no images attached then respond accordingly
	input = event.message.attachments											# Get the attached image
	return TRADE_TYPE unless (input[0].image?)									# If the attached file isn't an image, then respond accordingly

	numItems = File.read("./ext/meme/max").to_i									# Get the current image count
	output = Dir.glob("./ext/meme/" + rand(numItems + 1).to_s + ".*")			# Pick a random image

	numItems += 1																# Increase the max image count
	File.open("./ext/meme/max", 'w') { |f| f << numItems.to_s }					# Write back the updated item count
	newItem = numItems.to_s + input[0].filename.slice!(/\..*/)					# Create a new file with the new max number as its name, saving the extension
	IO.copy_stream(URI.open(input[0].url), "./ext/meme/" + newItem)				# Output the image to the opened file

	event.attach_file(File.open(output[0], 'r'))								# Return the randomly chosen image
end

$bot.command(:lewd) do |event|												# LEWD command
	return nil if (require_nsfw(event)) 										# Make sure the channel is marked as NSFW

	return TRADE_WARES if (event.message.attachments.empty?)					# If there are no images attached then respond accordingly
	input = event.message.attachments											# Get the attached image
	return TRADE_TYPE unless (input[0].image?)									# If the attached file isn't an image, then respond accordingly

	numItems = File.read("./ext/lewd/max").to_i									# Get the current image count
	output = Dir.glob("./ext/lewd/" + rand(numItems + 1).to_s + ".*")			# Pick a random image

	numItems += 1																# Increase the max image count
	File.open("./ext/lewd/max", 'w') { |f| f << numItems.to_s }					# Write back the updated item count
	newItem = numItems.to_s + input[0].filename.slice!(/\..*/)					# Create a new file with the new max number as its name, saving the extension
	IO.copy_stream(URI.open(input[0].url), "./ext/lewd/" + newItem)				# Output the image to the opened file

	event.attach_file(File.open(output[0], 'r'))								# Return the randomly chosen image
end

#============================================== GENERAL =============================================

$bot.command(:random, max_args: 1, min_args: 0) do |event, max|				# RANDOM Command
	max = '10' unless (max)														# If no max is specified, then use 10
	max = max.to_i

	return event.send_embed do |embed|											# Send the message as embedded
		embed.title = rand(max)													# Generate a random number
		embed.color = EMBED_MSG_COLOR
	end
end

$bot.command(:'8ball') do |event, *rest|									# 8BALL Command
	lines = IO.readlines("./ext/8ball.action").size 							# Get the number of lines
	return event.channel.send_embed do |embed|									# Return the message
		embed.description = "**" + IO.readlines("./ext/8ball.action")[rand(lines)].strip + " **" + "<@#{event.user.id}>"
		embed.color = EMBED_MSG_COLOR
	end
end

$bot.command(:rate, min_args: 1) do |event, *target|						# RATE Command
	user = Parser.get_user(target, event)									# Parse the target into a discord markup for IDs
	target = (user.nil?)? target.join(" ") : user.mention
	num = Random.new(target.sum).rand(11).to_s									# Generate a random number 0-10
	return event.channel.send_embed do |embed|									# Return the message
		embed.description = "I give **#{target}** a **#{num}/10**"				# Format string
		embed.color = EMBED_MSG_COLOR
	end
end

$bot.command(:katia) do |event, num|										# KATIA Command
	num = rand(1036).to_s unless (num)											# Supply a random index if no params are given
	index = num.to_i															# The item count is hard-coded here because images dont get added often
	output = Dir.glob("./ext/kat/#{index}.*")									# Pick a random image
	event.attach_file(File.open(output[0], 'r'))								# Send it
end

$bot.command(:chance, min_args: 1) do |event, *query|						# CHANCE Command
	query = query.join(" ")														# Stringify the globbed input params
	num = rand(11).to_s															# Generate a random number 0-10
	return event.channel.send_embed do |embed|									# Return the message
		embed.description = "I give the chance **#{query}** a **#{num}/10**"	# Format string
		embed.color = EMBED_MSG_COLOR
	end
end

$bot.command(:scp) do |event, query|										# SCP Command
	query = query.to_i															# Interpret the input as an int
	if (query < 0 || query > 5999)												# Check for invalid SCPs
		return event.channel.send_embed do |embed|
			embed.title = "Invalid SCP!"
			embed.color = EMBED_MSG_COLOR
		end
	else
		entry = query.to_s
		entry = entry.rjust(3, "0") if (query < 1000)							# For SCPs under 1-999, the number must be 3 digits long and right aligned

		return event.channel.send_embed do |embed|								# Return an embedded message
			embed.title = "http://www.scp-wiki.net/scp-#{entry}"				# Create the formatted URL
			embed.color = EMBED_MSG_COLOR
		end
	end
end

$bot.command(:e) do |event|													# E Command
	if (event.message.emoji?)												# Error out if the message doesn't have any emotes
		return event.channel.send_embed do |embed|								# Return error message
			embed.title = "Error"
			embed.description = "Message did not contain any valid emotes."
			embed.color = EMBED_MSG_COLOR
		end
	end
	event.channel.send_message(event.message.emoji[0].icon_url.gsub(".webp", ".png"))	# Respond with the URL of the first emote found
end

$bot.command(:a) do |event, *user|											# A Command
	user = Parser.get_user(user, event)										# Get a user object from a username fragment
	unless (user != nil)														# Error out if the user reference is invalid
		return event.channel.send_embed do |embed|								# Return error message
			embed.title = "Error"
			embed.description = "Invalid user."
			embed.color = EMBED_MSG_COLOR
		end
	end
	event.channel.send_message(user.avatar_url.gsub(".webp", ".png"))			# Respond with the URL of the user's avatar
end

$bot.command :uptime do |event|												# UPTIME Command
	seconds = (Time.now - $boottime).to_i										# Compute total seconds since program start
	days = Time.at(seconds).utc.strftime("%j").to_i - 1
	return event.channel.send_embed do |embed|									# Return embed with formatted time string
		embed.title = days.to_s + Time.at(seconds).utc.strftime(" days, %H:%M:%S")		# Format seconds into a human friendly string
		embed.color = EMBED_MSG_COLOR
	end
end

$bot.command :'define' do |event, *words|		# DEFINE Command
	pOS = ""										# Part of speech
	synonyms = ""
	definition = ""
	pnunce = ""										# Pronunciation
	fmtwords = words.join(' ')

	begin
		result = URI.open("https://api.dictionaryapi.dev/api/v2/entries/en/#{fmtwords}")
		result = JSON.parse(result.read)[0]

		meanings = result['meanings'][0]
		definitions = result['meanings'][0]['definitions'][0]
		phonetics = result['phonetics'][0]

		pOS 		= meanings['partOfSpeech']				if (meanings.has_key?('partOfSpeech'))
		definition	= definitions['definition']				if (definitions.has_key?('definition'))
		synonyms	= definitions['synonyms'].join(", ")	if (definitions.has_key?('synonyms'))
		pnunce		= phonetics['text'] 					if (phonetics.has_key?('text'))
	rescue
		begin
			result = URI.open("http://api.urbandictionary.com/v0/define?term=#{fmtwords}")
			result = JSON.parse(result.read)

			raise if (result.nil? || result['list'].nil? || result['list'].empty?)
		rescue
			return event.channel.send_embed do |embed|
				embed.title = "Error"
				embed.description = "No definitions were found for:\n**#{words.join(" ")}**"
				embed.color = EMBED_MSG_COLOR
			end
		end

		synonyms = "?"
		pOS = "?"
		pnunce = "?"
		definition = result['list'].sample['definition']
	end

	return event.channel.send_embed do |embed|
		embed.title = "#{words.join(" ")}   |   #{pnunce}   |   #{pOS}"
		embed.description = "**Definition**: #{definition} \n**Synonyms**: #{synonyms}"
		embed.color = EMBED_MSG_COLOR
	end
end

$bot.command :'urban' do |event, *words|									# URBAN Command
	pOS = ""																	# Part of speech
	synonyms = ""
	definition = ""
	pnunce = ""																	# Pronunciation
	fmtwords = words.join(' ')

	result = URI.open("http://api.urbandictionary.com/v0/define?term=#{fmtwords}")
	result = JSON.parse(result.read)

	debug_puts(result.inspect)

	if (result['list'].empty?)													# Error out if the list is empty
		return event.channel.send_embed do |embed|								# This means that no definitions were found on either site
			embed.title = "Error"
			embed.description = "No definitions were found for:\n**#{words.join(" ")}**"
			embed.color = EMBED_MSG_COLOR
		end
	end

	synonyms = "?"
	pOS = "?"
	pnunce = "?"
	definition = result['list'].sample['definition']

	return event.channel.send_embed do |embed|
		embed.title = "#{words.join(" ")}   |   #{pnunce}   |   #{pOS}"
		embed.description = "**Definition**: #{definition} \n**Synonyms**: #{synonyms}"
		embed.color = EMBED_MSG_COLOR
	end
end

#============================================= ACTIONS ==============================================

$bot.command :yiff do |event, *target| action(target, event, "yiff") end
$bot.command :hug do |event, *target| action(target, event, "hug") end
$bot.command :kiss do |event, *target| action(target, event, "kiss") end
$bot.command :stab do |event, *target| action(target, event, "stab") end
$bot.command :shoot do |event, *target| action(target, event, "shoot") end
$bot.command :pet do |event, *target| action(target, event, "pet") end
$bot.command :bless do |event, *target| action(target, event, "bless") end
$bot.command :f do |event, *target| action(target, event, "respects") end
$bot.command :nuke do |event, *target| action(target, event, "nuke") end
$bot.command :meow do |event, *target| action(target, event, "meow") end
$bot.command :grope do |event, *target| action(target, event, "grope") end
$bot.command :vore do |event, *target| action(target, event, "vore") end
$bot.command :boof do |event, *target| action(target, event, "boof") end

#=========================================== E621 FETCHING ==========================================

$bot.command :e6 do |event, *tags|											# E6 Command
	return nil if (require_nsfw(event)) 										# Make sure the channel is marked as NSFW
	if (tags.count > 5)															# Enforce tag limit
		return event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "Request had too many tags. Maximum number of tags is **5**"
			embed.color = EMBED_MSG_COLOR
		end
	end

	url = URI.parse("https://e621.net/posts.json")								# Parse base URI
	request = Net::HTTP::Get.new(url, 'Content-Type' => 'application/json')		# Create new HTTP request
	request.body = { limit: 1, tags: "order:random " + tags.join(" ") }.to_json	# Form the request
	request.add_field('User-Agent', 'Ruby')										# Add USER AGENT field to the request. E6 gets pissy if this field is blank
																				# Perform the actual HTTP GET
	result = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http| http.request(request)}

	post = JSON.parse(result.body)['posts'][0]									# Create a shorthand variable to reference the post
	if (post)																	# Proceed only if the post is populated with elements
		return nil if (require_blacklist(event, post, Blacklist_E621))			# Handle error conditions from blacklisted tags

		file = post['file']['url']												# Parse the URL of the image
		artist = post['tags']['artist'][0]										# Parse the name of the artist
		return event.channel.send_embed do |embed|								# Construct the returning embed
			embed.title = "Tags: " + tags.join(" ")
			embed.description = "Score: **#{post['score']['total']}**" +
				"  |  Favourites: **#{post['fav_count']}**" +
				"  |  [Post](https://e621.net/post/show/#{post['id']})"
			embed.image = Discordrb::Webhooks::EmbedImage.new(url: file)
			embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: artist, icon_url: 'https://e621.net/favicon.ico')
			embed.color = EMBED_MSG_COLOR
		end
	end

	return event.channel.send_embed do |embed|									# In the event that we can't parse any useful information back...
		embed.title = "Error"													# Assume that no images were found under the given tags and error out
		embed.description = "No posts matched your search:\n**#{tags.join(" ")}**"
		embed.color = EMBED_MSG_COLOR
	end
end

$bot.command :e9 do |event, *tags|											# E9 Command
	if (tags.count > 5)															# Enforce tag limit
		return event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "Request had too many tags. Maximum number of tags is **5**"
			embed.color = EMBED_MSG_COLOR
		end
	end

	url = URI.parse("https://e926.net/posts.json")								# Parse base URI
	request = Net::HTTP::Get.new(url, 'Content-Type' => 'application/json')		# Create new HTTP request
	request.body = { limit: 1, tags: "order:random " + tags.join(" ") }.to_json	# Form the request
	request.add_field('User-Agent', 'Ruby')										# Add USER AGENT field to the request. E6 gets pissy if this field is blank
																				# Perform the actual HTTP GET
	result = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http| http.request(request)}

	post = JSON.parse(result.body)['posts'][0]									# Create a shorthand variable to reference the post
	if (post)																	# Proceed only if the post is populated with elements
		return nil if (require_blacklist(event, post, Blacklist_E926))			# Handle error conditions from blacklisted tags

		file = post['file']['url']												# Parse the URL of the image
		artist = post['tags']['artist'][0]										# Parse the name of the artist
		return event.channel.send_embed do |embed|								# Construct the returning embed
			embed.title = "Tags: " + tags.join(" ")
			embed.description = "Score: **#{post['score']['total']}**" +
				"  |  Favourites: **#{post['fav_count']}**" +
				"  |  [Post](https://e926.net/post/show/#{post['id']})"
			embed.image = Discordrb::Webhooks::EmbedImage.new(url: file)
			embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: artist, icon_url: 'https://e621.net/favicon.ico')
			embed.color = EMBED_MSG_COLOR
		end
	end

	return event.channel.send_embed do |embed|									# In the event that we can't parse any useful information back...
		embed.title = "Error"													# Assume that no images were found under the given tags and error out
		embed.description = "No posts matched your search:\n**#{tags.join(" ")}**"
		embed.color = EMBED_MSG_COLOR
	end
end

$bot.command :'e6.blacklist' do |event, action, *tags|
	if (action == "get") then
		return event.channel.send_embed do |embed|
			embed.title = "Tag Blacklist"
			embed.description = Blacklist_E621.e621_black_tags.join(" ")
			embed.color = EMBED_MSG_COLOR
		end
	end

	if (tags[0].nil?) then
		return event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "No tags were specified for this action."
			embed.color = EMBED_MSG_COLOR
		end
	end

	if (action == "add")
		Blacklist_E621.e621_append_blacklist(tags)
	elsif (action == "remove")
		Blacklist_E621.e621_purge_blacklist(tags)
	else
		return nil
	end

	return event.channel.send_embed do |embed|
		embed.title = "Tag Blacklist"
		embed.description = "Blacklist modified."
		embed.color = EMBED_MSG_COLOR
	end
end

$bot.command :'e9.blacklist' do |event, action, *tags|
	if (action == "get")
		return event.channel.send_embed do |embed|
			embed.title = "Tag Blacklist"
			embed.description = Blacklist_E926.e621_black_tags.join(" ")
			embed.color = EMBED_MSG_COLOR
		end
	end

	if (tags[0].nil?)
		return event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "No tags were specified for this action."
			embed.color = EMBED_MSG_COLOR
		end
	end

	if (action == "add")
		Blacklist_E926.e621_append_blacklist(tags)
	elsif (action == "remove")
		Blacklist_E926.e621_purge_blacklist(tags)
	else
		return nil
	end

	return event.channel.send_embed do |embed|
		embed.title = "Tag Blacklist"
		embed.description = "Blacklist modified."
		embed.color = EMBED_MSG_COLOR
	end
end

#============================================ INTERNAL ==============================================

$bot.command(:usermod, max_args: 2, min_args: 2) do |event, target, level|		# USERMOD Command
	target = Parser.get_user(target).id
	return nil if (target.nil?)
	return "Naughty! You are not an administrator." unless PList.query(event.user.id, 2)
	return "User is already on list." if (PList.add(target, level).nil?)
	return "User permissions updated."
end

$bot.command(:servermod, max_args: 0, min_args: 0) do |event|					# SERVERMOD Command
	return "Naughty! You are not an administrator." unless PList.query(event.user.id, 2)

	i = 0
	while event.server.members[i] != nil do
		PList.add(event.server.members[i].id, 1) unless PList.is_exist(event.server.members[i].id)
		i += 1
	end
	return "User permissions updated."
end

$bot.command(:listmod, max_args: 0) do |event|									# LISTMOD Command
	PList.list(event)
	return nil
end

#====================================================================================================
