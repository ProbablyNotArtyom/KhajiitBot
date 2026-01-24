#
# MIT License
#
# Copyright (c) 2024 Carson Herrington
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
# KhajiitBot - NotArtyom - 2024
# ----------------------------------------
# Command functions
#====================================================================================================

# TODO: replace all event.send_message and event.send_embed with proper event.respond

KIRL_ID=435552638604673025

module Application
	class Bot < Discordrb::Bot
		def slash_command(name, description)
			$bot.register_application_command(name, description, KIRL_ID)
			return $bot.application_command(name)
		end

		def slash_unregister_all()
			$bot.get_application_commands().each do |x|
				$bot.delete_application_command(x.id)
			end
		end
	end
end

# Help command
$bot.command(:help) do |event, *type|
	type = type.join(" ")

	# Send embedded help message
	return event.send_embed do |embed|
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

TRADE_WARES = "This one is displeased with your lack of wares..."						# Error message for when no image is given
TRADE_INVALID_TYPE = "This one does not think that your wares are of proper type..."	# Error message for when the input file isn't an image

# IMAGE command
$bot.command(:image) do |event|
	numItems = File.read("./ext/meme/max").to_i									# Get the current image count
	output = Dir.glob("./ext/meme/" + rand(numItems + 1).to_s + ".*")			# Pick a random image
	event.attach_file(File.open(output[0], 'r'))								# Return the randomly chosen image
end

# AROUSE Command
$bot.command(:arouse) do |event|
	return nil if (require_nsfw(event)) 										# Make sure the channel is marked as NSFW

	numItems = File.read("./ext/lewd/max").to_i									# Get the current image count
	output = Dir.glob("./ext/lewd/" + rand(numItems + 1).to_s + ".*")			# Pick a random image
	event.attach_file(File.open(output[0], 'r'))								# Return the randomly chosen image
end

# TRADE Command
$bot.command(:trade) do |event|
	return TRADE_WARES if (event.message.attachments.empty?)					# If there are no images attached then respond accordingly
	input = event.message.attachments											# Get the attached image
	return TRADE_INVALID_TYPE unless (input[0].image?)							# If the attached file isn't an image, then respond accordingly

	numItems = File.read("./ext/meme/max").to_i									# Get the current image count
	output = Dir.glob("./ext/meme/" + rand(numItems + 1).to_s + ".*")			# Pick a random image

	numItems += 1																# Increase the max image count
	File.open("./ext/meme/max", 'w') { |f| f << numItems.to_s }					# Write back the updated item count
	newItem = numItems.to_s + input[0].filename.slice!(/\..*/)					# Create a new file with the new max number as its name, saving the extension
	IO.copy_stream(URI.open(input[0].url), "./ext/meme/" + newItem)				# Output the image to the opened file

	event.attach_file(File.open(output[0], 'r'))								# Return the randomly chosen image
end

# LEWD command
$bot.command(:lewd) do |event|
	return nil if (require_nsfw(event)) 										# Make sure the channel is marked as NSFW

	return TRADE_WARES if (event.message.attachments.empty?)					# If there are no images attached then respond accordingly
	input = event.message.attachments											# Get the attached image
	return TRADE_INVALID_TYPE unless (input[0].image?)							# If the attached file isn't an image, then respond accordingly

	numItems = File.read("./ext/lewd/max").to_i									# Get the current image count
	output = Dir.glob("./ext/lewd/" + rand(numItems + 1).to_s + ".*")			# Pick a random image

	numItems += 1																# Increase the max image count
	File.open("./ext/lewd/max", 'w') { |f| f << numItems.to_s }					# Write back the updated item count
	newItem = numItems.to_s + input[0].filename.slice!(/\..*/)					# Create a new file with the new max number as its name, saving the extension
	IO.copy_stream(URI.open(input[0].url), "./ext/lewd/" + newItem)				# Output the image to the opened file

	event.attach_file(File.open(output[0], 'r'))								# Return the randomly chosen image
end

#============================================== GENERAL =============================================

# RANDOM Command
$bot.command(:random, max_args: 1, min_args: 0) do |event, max|
	max = '10' unless (max)														# If no max is specified, then use 10
	max = max.to_i

	return event.send_embed do |embed|											# Send the message as embedded
		embed.title = rand(max)													# Generate a random number
		embed.color = EMBED_MSG_COLOR
	end
end

# 8BALL Command
$bot.command(:'8ball') do |event, *rest|
	lines = IO.readlines("./ext/8ball.strings") 								# Get the strings
	return event.channel.send_embed do |embed|									# Return the message
		embed.description = "**" + lines[rand(lines.size)].strip + " **" + "<@#{event.user.id}>"
		embed.color = EMBED_MSG_COLOR
	end
end

# RATE Command
$bot.command(:rate, min_args: 1) do |event, *target|
	user = Parser.get_user(target, event)										# Parse the target into a discord markup for IDs
	target = (user.nil?)? target.join(" ") : user.mention
	num = Random.new(target.sum).rand(11).to_s									# Generate a random number 0-10
	return event.channel.send_embed do |embed|									# Return the message
		embed.description = "I give **#{target}** a **#{num}/10**"				# Format string
		embed.color = EMBED_MSG_COLOR
	end
end

# KATIA Command
$bot.command(:katia) do |event, num|
	num = rand(1036).to_s unless (num)											# Supply a random index if no params are given
	index = num.to_i															# The item count is hard-coded here because images dont get added often
	output = Dir.glob("./ext/kat/#{index}.*")									# Pick a random image
	event.attach_file(File.open(output[0], 'r'))								# Send it
end

# CHANCE Command
$bot.command(:chance, min_args: 1) do |event, *query|
	query = query.join(" ")														# Stringify the globbed input params
	num = rand(11).to_s															# Generate a random number 0-10
	return event.channel.send_embed do |embed|									# Return the message
		embed.description = "I give the chance **#{query}** a **#{num}/10**"	# Format string
		embed.color = EMBED_MSG_COLOR
	end
end

# SCP Command
SCP_MAX = 9999
$bot.command(:scp) do |event, *query|
	if (query.empty?)
		query = rand(SCP_MAX+1)										# No input, so generate a random SCP entry
	else
		query = query.join("").to_i									# Interpret the input as an int
	end

	if (query < 0 || query > SCP_MAX)								# Check for invalid SCPs
		return event.channel.send_embed do |embed|
			embed.title = "Invalid SCP!"
			embed.color = EMBED_MSG_COLOR
		end
	else
		entry = query.to_s
		entry = entry.rjust(3, "0") if (query < 1000)				# For SCPs under 1-999, the number must be 3 digits long and right aligned

		return event.channel.send_embed do |embed|					# Return an embedded message
			embed.title = "http://www.scp-wiki.net/scp-#{entry}"	# Create the formatted URL
			embed.color = EMBED_MSG_COLOR
		end
	end
end

# E Command
$bot.command(:e) do |event|
	if (event.message.emoji?)							# Error out if the message doesn't have any emotes
		return event.channel.send_embed do |embed|		# Return error message
			embed.title = "Error"
			embed.description = "Message did not contain any valid emotes."
			embed.color = EMBED_ERROR_COLOR
		end
	end
	event.channel.send_message(event.message.emoji[0].icon_url.gsub(".webp", ".png"))	# Respond with the URL of the first emote found
end

# A Command
$bot.command(:a) do |event, *user|
	if (user.empty?)
		user = event.message.author						# Act on self if input is empty
	else
		user = Parser.get_user(user, event)				# Get a user object from a username fragment
	end

	unless (user != nil)								# Error out if the user reference is invalid
		return event.channel.send_embed do |embed|		# Return error message
			embed.title = "Error"
			embed.description = "Invalid user."
			embed.color = EMBED_ERROR_COLOR
		end
	end
	event.channel.send_message(user.avatar_url.gsub(".webp", ".png"))		# Respond with the URL of the user's avatar
end

# UPTIME Command
$bot.command(:uptime) do |event|
	seconds = (Time.now - $boottime).to_i											# Compute total seconds since program start
	days = Time.at(seconds).utc.strftime("%j").to_i - 1
	return event.channel.send_embed do |embed|										# Return embed with formatted time string
		embed.title = days.to_s + Time.at(seconds).utc.strftime(" days, %H:%M:%S")	# Format seconds into a human friendly string
		embed.color = EMBED_MSG_COLOR
	end
end

# DEFINE Command
$bot.command(:define) do |event, *words|
	pOS = ""			# Part of speech
	synonyms = ""		# Synonyms
	pnunce = ""			# Pronunciation
	definition = ""		# Definition
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
				embed.color = EMBED_ERROR_COLOR
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

# URBAN Command
$bot.command(:urban) do |event, *words|
	pOS = "?"			# Part of speech
	synonyms = "?"		# Synonyms
	pnunce = "?"		# Pronunciation
	definition = ""		# Definition
	fmtwords = words.join(' ')

	result = URI.open("http://api.urbandictionary.com/v0/define?term=#{fmtwords}")
	result = JSON.parse(result.read)

	DEBUG_PUTS(result.inspect)

	if (result['list'].empty?)							# Error out if the list is empty
		return event.channel.send_embed do |embed|		# This means that no definitions were found on either site
			embed.title = "Error"
			embed.description = "No definitions were found for:\n**#{words.join(" ")}**"
			embed.color = EMBED_ERROR_COLOR
		end
	end

	definition = result['list'].sample['definition']	# Extract definition

	return event.channel.send_embed do |embed|
		embed.title = "#{words.join(" ")}   |   #{pnunce}   |   #{pOS}"
		embed.description = "**Definition**: #{definition} \n**Synonyms**: #{synonyms}"
		embed.color = EMBED_MSG_COLOR
	end
end

#============================================== QUOTE ===============================================

# TIME Command
$bot.command(:time) do |event, *words|
	lines = IO.readlines("./ext/timecube.strings")							# Get the quote strings
	return event.channel.send_embed do |embed|								# Pick a random one and respond
		embed.title = "Gene Ray:"
		embed.description = "\"*#{lines[rand(lines.size)].strip}*\""
		embed.color = EMBED_MSG_COLOR
	end
end

#============================================= ACTIONS ==============================================

$bot.command(:yiff) do |event, *target| action(target, event, "yiff") end		# YIFF action command
$bot.command(:hug) do |event, *target| action(target, event, "hug") end			# HUG action command
$bot.command(:kiss) do |event, *target| action(target, event, "kiss") end		# KISS action command
$bot.command(:stab) do |event, *target| action(target, event, "stab") end		# STAB action command
$bot.command(:shoot) do |event, *target| action(target, event, "shoot") end		# SHOOT action command
$bot.command(:pet) do |event, *target| action(target, event, "pet") end			# PET action command
$bot.command(:bless) do |event, *target| action(target, event, "bless") end		# BLESS action command
$bot.command(:f) do |event, *target| action(target, event, "respects") end		# F action command
$bot.command(:nuke) do |event, *target| action(target, event, "nuke") end		# NUKE action command
$bot.command(:meow) do |event, *target| action(target, event, "meow") end		# MEOW action command
$bot.command(:grope) do |event, *target| action(target, event, "grope") end		# GROPE action command
$bot.command(:vore) do |event, *target| action(target, event, "vore") end		# VORE action command
$bot.command(:boof) do |event, *target| action(target, event, "boof") end		# BOOF action command

#=========================================== E621 FETCHING ==========================================

# Handles searching for both sites
E6_REQUEST_SIZE = 25
def command_e621_e926(event, tags, site_url, blacklist)
	# Enforce tag limit
	if (tags.count > 5)
		return event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "Request had too many tags. Maximum number of tags is **5**"
			embed.color = EMBED_ERROR_COLOR
		end
	end

	# Dont bother if a blacklisted tag is searched
	invalid = blacklist.check_tags(tags)
	unless (invalid.empty?)
		return event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "Search contained a blacklisted tag: **#{invalid.join(", ")}**"
			embed.color = EMBED_ERROR_COLOR
		end
	end

	url = URI.parse("#{site_url}/posts.json")										# Parse base URI
	request = Net::HTTP::Get.new(url, 'Content-Type' => 'application/json')			# Create new HTTP request
	request.body = { limit: E6_REQUEST_SIZE, tags: "order:random " + tags.join(" ") }.to_json
	request.add_field('User-Agent', 'Ruby')											# Add USER AGENT field to the request. E6 gets pissy if this field is blank
	# Perform the actual HTTP GET
	result = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http| http.request(request)}
	response = JSON.parse(result.body)
	if (result.is_a?(Net::HTTPSuccess))
		posts = response['posts']										# Create array of all posts recieved
		if (posts[0] == nil)											# No posts found matching the query
			return event.channel.send_embed do |embed|
				embed.title = "Error"
				embed.description = "No posts matched your search:\n**#{tags.join(" ")}**"
				embed.color = EMBED_ERROR_COLOR
			end
		end

		if (posts != nil)
			DEBUG_PUTS("e621 page length: #{posts.length}")
			posts.each_with_index do |x, i|								# Iterate over posts to try and find one that isn't blacklisted
				taglist = []
				x['tags'].each_value {|y| taglist = taglist + y}
				blacklisted = blacklist.check_tags(taglist)				# Check for blacklisted tags
				if (blacklisted.empty?) 								# Found something with no blacklist hits
					return event.channel.send_embed do |embed|			# Construct the returning embed
						embed.title = "Tags: " + tags.join(" ")
						embed.description = "Score: **#{x['score']['total']}**" +
							"  |  Favourites: **#{x['fav_count']}**" +
							"  |  [Post](#{site_url}/post/show/#{x['id']})"
						embed.image = Discordrb::Webhooks::EmbedImage.new(url: x['file']['url'])
						embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: x['tags']['artist'].join(", "), icon_url: "#{site_url}/favicon.ico")
						embed.color = EMBED_MSG_COLOR
					end
				end
			end
		end

		# Either no posts matched, or couldnt find a post without blacklsited tags
		return event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "Could not find a non blacklisted post within #{E6_REQUEST_SIZE} tries. Try again"
			embed.color = EMBED_ERROR_COLOR
		end
	else
		return event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "#{response['reason']}"
			embed.color = EMBED_ERROR_COLOR
		end
	end
end

# E6 Command
$bot.command(:e6) do |event, *tags|
	return nil if (require_nsfw(event))		# Make sure the channel is marked as NSFW
	command_e621_e926(event, tags, "https://e621.net", Blacklist_E621)
end

# E9 Command
$bot.command(:e9) do |event, *tags|
	command_e621_e926(event, tags, "https://e926.net", Blacklist_E926)
end

# Handles blacklist for both sites
def command_blacklist_e621_e926(event, action, tags, blacklist)
	if (action == "get")
		return event.channel.send_embed do |embed|
			embed.title = "Tag Blacklist"
			embed.description = (blacklist.e621_black_tags.empty?)? "" : blacklist.e621_black_tags.join(" ")
			embed.color = EMBED_MSG_COLOR
		end
	end

	if (action == "clear")
		blacklist.clear()
		return event.channel.send_embed do |embed|
			embed.title = "Tag Blacklist"
			embed.description = "Blacklist cleared."
			embed.color = EMBED_MSG_COLOR
		end
	end

	if (action == "help" || action == nil)
		return event.channel.send_embed do |embed|
			embed.title = "Available options"
			embed.description = "get : Returns the blacklist\n" +
				"add <tags> : Adds tags to the blacklist\n" +
				"clear : Clears the entire blacklist\n" +
				"remove <tags> : Removes tags from the blacklist\n" +
				"\n" +
				"<tags> is a list of tags seperated by spaces"

			embed.color = EMBED_MSG_COLOR
		end
	end

	if (tags[0].nil?)
		return event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "No tags were specified for this action."
			embed.color = EMBED_ERROR_COLOR
		end
	else
		if (action == "add")
			blacklist.append(tags)
			return event.channel.send_embed do |embed|
				embed.title = "Tag Blacklist"
				embed.description = "Added #{tags.length} tags."
				embed.color = EMBED_MSG_COLOR
			end
		elsif (action == "remove")
			blacklist.remove(tags)
			return event.channel.send_embed do |embed|
				embed.title = "Tag Blacklist"
				embed.description = "Removed #{tags.length} tags."
				embed.color = EMBED_MSG_COLOR
			end
		end
	end
end

$bot.command(:'e6.blacklist', {:required_permissions => [:manage_channels]}) do |event, action, *tags|
	return if (event.channel.type == Discordrb::Channel::TYPES[:dm])	# Ignore use in DMs
	command_blacklist_e621_e926(event, action, tags, Blacklist_E621)
end

$bot.command(:'e9.blacklist') do |event, action, *tags|
	return if (event.channel.type == Discordrb::Channel::TYPES[:dm])	# Ignore use in DMs
	command_blacklist_e621_e926(event, action, tags, Blacklist_E926)
end

#====================================================================================================

$bot.command(:prune, {:required_permissions => [:manage_channels]}) do |event, number="1"|
	number = number.to_i
	pins = event.channel.pins
	for i in 1..number do
		DEBUG_PUTS "#{i}"
		pins[-i].unpin
	end
	return nil
end


#====================================================================================================
