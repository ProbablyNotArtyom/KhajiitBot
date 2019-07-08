
#==================================================
#     KhajiitBot  --  NotArtyom  --  03/06/18
#==================================================
#                Command functions
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

$bot.command :help do |event, *type|			# Help command
	type = type.join(" ")
	begin
		event.message.delete					# Delete the help in case somthing implodes
	rescue
	end
	event.channel.send_embed do |embed|			# Send embedded help message
		embed.thumbnail = Discordrb::Webhooks::EmbedImage.new(url: 'http://i.imgur.com/pG3L2RP.png')
		embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'KhajiitBot', url: 'https://discordapp.com/oauth2/authorize?client_id=452660556990644225&scope=bot&permissions=0', icon_url: 'http://i.imgur.com/pG3L2RP.png')
		if type.empty? then
			embed.add_field(name: 'k.help usage:', value: IO.read("./ext/help/meta").force_encoding("utf-8"))
		else
			if File.file?("./ext/help/#{type}") then
				embed.add_field(name: "#{type.slice(0, 1).capitalize + type.slice(1..-1)} Commands:", value: IO.read("./ext/help/#{type}").force_encoding("utf-8"))
			else
				embed.add_field(name: 'Error!', value: 'Invalid help type. Please use on option from the list')
			end
		end
		embed.color = 0xa21a5d
	end
	return nil
end

$bot.command(:trade) do |event|												# TRADE Command
	if event.message.attachments.empty? then								# If there are no images attached then respond accordingly
		event.respond("This one is displeased with your lack of wares...")
		return nil
	end
	files = event.message.attachments										# Get the attached image
	unless files[0].image? then												# If the attached file isnt an image then respond accordingly
		event.respond("This one does not think that your wares are of proper type...")
		return nil
	end
	download = open(files[0].url)											# Download the image
	oname = File.read("./ext/meme/max").to_i								# See what the current number of images is
	event.send_file(File.open(Dir.glob("./ext/meme/#{rand(oname).to_s}.*")[0], 'r'))	# Pick a random image and send it back
	oname += 1																# Increase the max image count
	File.open("./ext/meme/max", 'w') { |f| f << oname.to_s }				# Open a new image
	oname = "./ext/meme/" + oname.to_s + files[0].filename.slice!(/\..*/)	# Create a new file with the new max number as its name, saving the extension
	IO.copy_stream(download, oname)											# Output the image to the opened file
	return nil
end

$bot.command(:image) do |event|												# IMAGE command
	oname = File.read("./ext/meme/max").to_i								# See what the current number of images is
	event.send_file(File.open(Dir.glob("./ext/meme/#{rand(oname).to_s}.*")[0], 'r'))	# Pick a random image and send it back
	return nil
end

$bot.command(:lewd) do |event|												# LEWD command
	unless event.channel.nsfw? then 										# Make sure the channel is marked as NSFW
		event.channel.send_embed do |embed|
			embed.title = "```Use this command in an NSFW marked channel.```"
			embed.color = 0xa21a5d
		end
		return nil
	end
	if event.message.attachments.empty? then								# If the attached file isnt existant then respond accordingly
		event.respond("This one is displeased with your lack of wares...")
		return nil
	end
	files = event.message.attachments										# Get the attached file
	unless files[0].image? then												# If the attached file isnt an image then respond accordingly
		event.respond("This one does not think that your wares are of proper type...")
		return nil
	end
	download = open(files[0].url)											# Download the image
	oname = File.read("./ext/lewd/max").to_i								# See what the current number of images is
	event.send_file(File.open(Dir.glob("./ext/lewd/#{rand(oname).to_s}.*")[0], 'r'))	# Pick a random image and send it back
	oname += 1																# Increase the max image count
	File.open("./ext/lewd/max", 'w') { |f| f << oname.to_s }				# Open a new image
	oname = "./ext/lewd/" + oname.to_s + files[0].filename.slice!(/\..*/)	# Create a new file with the new max number as its name, saving the extension
	IO.copy_stream(download, oname)											# Output the image to the opened file
	return nil
end

$bot.command(:arouse) do |event|
	unless event.channel.nsfw? then
		event.channel.send_embed do |embed|
			embed.title = "```Use this command in an NSFW marked channel.```"
			embed.color = 0xa21a5d
		end
		return nil
	end
	oname = File.read("./ext/lewd/max").to_i                                		  	# See what the current number of images is
    event.send_file(File.open(Dir.glob("./ext/lewd/#{rand(oname).to_s}.*")[0], 'r'))    # Pick a random image and send it back
	return nil
end

$bot.command(:random, max_args: 1, min_args: 0) do |event, max|				# RANDOM Command
	if max == nil then max = 10 											# If the max is not specified, then use 10
	else max = max.to_i end
	event.channel.send_embed do |embed|										# Send the message as embedded
		embed.title = rand(max)												# Generate a random number
		embed.color = 0xa21a5d
	end
	return nil
end

$bot.command(:'8ball') do |event, *rest|									# 8BALL Command
	lines = IO.readlines("./ext/8ball").size 								# Get the number of lines
	if rest.include? "sleep"
		event.channel.send_embed do |embed|                                     # Return the message
        	embed.title = "I dont think so," + event.user.name
        	embed.color = 0xa21a5d
		end
	else
		event.channel.send_embed do |embed|										# Return the message
			embed.title = IO.readlines("./ext/8ball")[rand(lines)] + event.user.name
			embed.color = 0xa21a5d
		end
	end
	return nil
end

$bot.command(:rate, min_args: 1) do |event, *target|						# RATE Command
	target = Parser.get_target(target, event)								# Parse the target into a discord markup for IDs
	event.channel.send_embed do |embed|
		embed.description = "I give " + target + " a " + rand(10).to_s + "/10"	# Generate a random number 0-10
		embed.color = 0xa21a5d
	end
	return nil
end

$bot.command(:katia) do |event, num|										# KATIA Command
	if num == nil
		index = rand(1036).to_s
	else
		index = Integer(num) rescue index = "hitler"
	end
	event.send_file(File.open(Dir.glob("./ext/kat/#{index}.*")[0], 'r'))	# Pick a random image and send it. The MAX is hard-coded here because you probably wont add images much
	return nil
end

$bot.command(:chance, min_args: 1) do |event, *query|						# CHANCE Command
	event.channel.send_embed do |embed|															# Return the message
		embed.title = "I give the chance " + query.join(" ") + " a " + rand(10).to_s + "/10"	# Generate a random number 0-10
		embed.color = 0xa21a5d
	end
	return nil
end

$bot.command(:scp) do |event, query|						# SCP Command
	query = query.to_i
	if query <= 0 || query >= 5000 then
		event.channel.send_embed do |embed|
			embed.title = "Invalid SCP!"
			embed.color = 0xa21a5d
		end
	else
		if query < 1000 then
			query = query.to_s.rjust(3, "0")
		else
			query = query.to_s
		end
		event.channel.send_embed do |embed|
			embed.title = "http://www.scp-wiki.net/scp-#{query}"
			embed.color = 0xa21a5d
		end
	end
	return nil
end

$bot.command(:e) do |event|
	if (event.message.emoji?) then
		#event.channel.send_embed do |embed|
		#	embed.image = Discordrb::Webhooks::EmbedImage.new(url: event.message.emoji[0].icon_url)
		#	embed.color = 0xa21a5d
		event.channel.send_message(event.message.emoji[0].icon_url)
		#end
	else
		event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "Message did not contain any valid emotes."
			embed.color = 0xa21a5d
		end
	end
	return nil
end

$bot.command(:a) do |event, user|
	user = Parser.get_user_obj(user, event)
	if (user != nil) then
		#event.channel.send_embed do |embed|
		#	embed.image = Discordrb::Webhooks::EmbedImage.new(url: user.avatar_url)
		#	embed.color = 0xa21a5d
		event.channel.send_message(user.avatar_url)
		#end
	else
		event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "Invalid user."
			embed.color = 0xa21a5d
		end
	end
	return nil
end

$bot.command :yiff do |event, *target|		# YIFF Command
	action(target, event, "yiff")			# Execute command handler using the proper stringset
	return nil
end

$bot.command :hug do |event, *target|		# HUG Command
	action(target, event, "hug")			# Execute command handler using the proper stringset
	return nil
end

$bot.command :kiss do |event, *target|		# KISS Command
	action(target, event, "kiss")			# Execute command handler using the proper stringset
	return nil
end

$bot.command :stab do |event, *target|		# STAB Command
	action(target, event, "stab")			# Execute command handler using the proper stringset
	return nil
end

$bot.command :shoot do |event, *target|		# SHOOT Command
	action(target, event, "shoot")			# Execute command handler using the proper stringset
	return nil
end

$bot.command :pet do |event, *target|		# PET Command
	action(target, event, "pet")			# Execute command handler using the proper stringset
	return nil
end

$bot.command :bless do |event, *target|		# BLESS Command
	action(target, event, "bless")			# Execute command handler using the proper stringset
	return nil
end

$bot.command :f do |event, *target|			# RESPECTS Command
	action(target, event, "respects")		# Execute command handler using the proper stringset
	return nil
end

$bot.command :nuke do |event, *target|		# NUKE Command
	action(target, event, "nuke")			# Execute command handler using the proper stringset
	return nil
end

$bot.command :meow do |event, *target|		# MEOW Command
	action(target, event, "meow")			# Execute command handler using the proper stringset
	return nil
end

$bot.command :grope do |event, *target|		# NUKE Command
	action(target, event, "grope")			# Execute command handler using the proper stringset
	return nil
end

$bot.command :vore do |event, *target|		# VORE Command
	action(target, event, "vore")			# Execute command handler using the proper stringset
	return nil
end

$bot.command :boof do |event, *target|		# BOOF Command
	action(target, event, "boof")			# Execute command handler using the proper stringset
	return nil
end

$bot.command :uptime do |event|
	uptime_seconds = Time.now.to_i - $boottime.to_i
	uptime_hours = uptime_seconds/1440 % 1
	event.channel.send_embed do |embed|
		embed.title = uptime_hours.to_s + " hours, " + (uptime_seconds - uptime_hours*1440).to_s + " seconds."
		embed.color = 0xa21a5d
	end
end

$bot.command :e6 do |event, *tags|
	unless event.channel.nsfw? then 										# Make sure the channel is marked as NSFW
		event.channel.send_embed do |embed|
			embed.title = "```Use this command in an NSFW marked channel.```"
			embed.color = 0xa21a5d
		end
		return nil
	end

	url = URI.parse("https://e621.net/post/index.json")
	request = Net::HTTP::Get.new(url, 'Content-Type' => 'application/json')
	request.body = {
		limit:	1,
		tags:	"order:random " + tags.join(" ")
	}.to_json

	request.add_field('User-Agent', 'Ruby')
	result = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
		http.request(request)
	end

	if (result.body != "[]") then
		# Check the blacklist
		black_tags = JSON.parse(result.body)[0]['tags'].split(" ")
		if (Blacklist.e621_screen_tags(black_tags) == false) then
			event.channel.send_embed do |embed|
				embed.title = "Error"
				embed.description = "Post contained one or more blacklisted tags."
				embed.color = 0xa21a5d
			end
			return nil
		end

		file = JSON.parse(result.body)[0]['file_url']
		artist = JSON.parse(result.body)[0]['author']
		event.channel.send_embed do |embed|
			embed.title = "Tags: " + tags.join(" ")
			embed.description = "Score: **" + JSON.parse(result.body)[0]['score'].to_s + "**" +
				" # Favourites: **" + JSON.parse(result.body)[0]['fav_count'].to_s + "**" +
				" # [Post](https://e621.net/post/show/#{JSON.parse(result.body)[0]['id'].to_s})"
			embed.image = Discordrb::Webhooks::EmbedImage.new(url: file)
			embed.color = 0xa21a5d
		end
	else
		event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "No posts matched your search:
				**" + tags.join(" ") + "**"
			embed.color = 0xa21a5d
		end
	end
end

$bot.command :e9 do |event, *tags|
	url = URI.parse("https://e926.net/post/index.json")
	request = Net::HTTP::Get.new(url, 'Content-Type' => 'application/json')
	request.body = {
		limit:	1,
		tags:	"order:random " + tags.join(" ")
	}.to_json

	request.add_field('User-Agent', 'Ruby')
	result = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
		http.request(request)
	end

	if (result.body != "[]") then
		# Check the blacklist
		black_tags = JSON.parse(result.body)[0]['tags'].split(" ")
		if (Blacklist.e621_screen_tags(black_tags) == false) then
			event.channel.send_embed do |embed|
				embed.title = "Error"
				embed.description = "Post contained one or more blacklisted tags."
				embed.color = 0xa21a5d
			end
			return nil
		end

		file = JSON.parse(result.body)[0]['file_url']
		artist = JSON.parse(result.body)[0]['author']
		event.channel.send_embed do |embed|
			embed.title = "Tags: " + tags.join(" ")
			embed.description = "Score: **" + JSON.parse(result.body)[0]['score'].to_s + "**" +
				" # Favourites: **" + JSON.parse(result.body)[0]['fav_count'].to_s + "**" +
				" # [Post](https://e926.net/post/show/#{JSON.parse(result.body)[0]['id'].to_s})"
			embed.image = Discordrb::Webhooks::EmbedImage.new(url: file)
			embed.color = 0xa21a5d
		end
	else
		event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "No posts matched your search:
				**" + tags.join(" ") + "**"
			embed.color = 0xa21a5d
		end
	end
end

$bot.command :'e6.blacklist' do |event, action, *tags|
	if (action == "get") then
		event.channel.send_embed do |embed|
			embed.title = "Tag Blacklist"
			embed.description = Blacklist.e621_get_blacklist().join(" ")
			embed.color = 0xa21a5d
		end
		return nil;
	end

	if (tags[0] == nil) then
		event.channel.send_embed do |embed|
			embed.title = "Error"
			embed.description = "No tags were specified for this action."
			embed.color = 0xa21a5d
		end
		return nil;
	end
	if (action == "add") then
		Blacklist.e621_append_blacklist(tags)
	elsif (action == "remove")
		Blacklist.e621_purge_blacklist(tags)
	else
		return nil
	end
	event.channel.send_embed do |embed|
		embed.title = "Tag Blacklist"
		embed.description = "Blacklist modified."
		embed.color = 0xa21a5d
	end
	return nil
end

module Urban
  module_function

  URL = 'http://api.urbandictionary.com/v0/define'

  # Gets the definitions for the word.
  # @param word [String] The word to define.
  # @return [Array<Slang>] An array of #{Slang} objects.
  def define(word)
    params = {
      term: word
    }
    @client = HTTPClient.new if @client.nil?
    response = JSON.parse(@client.get(URI.parse(URL), params).body)
    ret = []
    response['list'].each do |hash|
      ret << Slang.new(hash)
    end
    ret
  end
end

$bot.command :'define' do |event, *words|
	pOS = ""
	synonyms = ""
	definition = ""
	pnunce = ""
	begin
		result = open("https://wordsapiv1.p.mashape.com/words/#{words[0]}",
			"User-Agent" => "Ruby/#{RUBY_VERSION}",
			"X-Mashape-Key" => $wordsapi_key)
	rescue
		result = open("http://api.urbandictionary.com/v0/define?term=#{words[0]}").read
		result = JSON.parse(result)

		synonyms = "none"
		pOS = "none"
		pnunce = "none"
		definition = result['list'].sample['definition']
	else
		result = JSON.parse(result.read)
		if (result['results'][0].has_key?('partOfSpeech') == true) then pOS=result['results'][0]['partOfSpeech'] else pOS="none" end
		if (result['results'][0].has_key?('synonyms') == true) then synonyms=result['results'][0]['synonyms'].join(", ") else synonyms="none" end
		if (result['results'][0].has_key?('definition') == true) then definition=result['results'][0]['definition'] else definition="none" end
		if (result['pronunciation'].has_key?(pOS) == true) then pnunce=result['pronunciation'][pOS]
		elsif (result['pronunciation'].has_key?('all') == true) then pnunce=result['pronunciation']['all']
		else pnunce="none" end
	end

	event.channel.send_embed do |embed|
		embed.title = "**#{words.join(" ")}** | #{pnunce} | #{pOS}"
		embed.description = "**Definition**: #{definition}
			**Synonyms**: #{synonyms}"
		embed.color = 0xa21a5d
	end
end

#=================INTERNAL PROMPT==================

$bot.command(:blacklist) do |event, func, target|								# BLACKLIST Command
	unless PList.query(event.user.id, 2) then event.respond("Naughty! You are not an administrator."); return nil end
	if func == "list" then BList.list(event, target); return nil end
	target = Parser.get_uid(target, event)
	if func == "remove"
		$bot.unignore_user(target)
	elsif func == "add"
		$bot.ignore_user(target)
	else event.respond "Invalid operation. valid operations are: remove add list"; return nil
	end
	event.respond "Blacklist updated."
	return nil
end

$bot.command(:usermod, max_args: 2, min_args: 2) do |event, target, level|		# USERMOD Command
	target = Parser.get_uid(target, event)
	if target == nil then return nil end
	unless PList.query(event.user.id, 2) then event.respond("Naughty! You are not an administrator.")
		return nil
	end
	if PList.add(target, level) == nil then event.respond "User is already on list."
	else event.respond "User permissions updated." end
	return nil
end

$bot.command(:servermod, max_args: 0, min_args: 0) do |event|					# SERVERMOD Command
	unless PList.query(event.user.id, 2) then event.respond("Naughty! You are not an administrator.")
		return nil
	end
	i = 0
	while event.server.members[i] != nil do
		unless PList.is_exist(event.server.members[i].id) then PList.add(event.server.members[i].id, 1) end
		i += 1
	end
	event.respond "User permissions updated."
end

$bot.command(:listmod, max_args: 0) do |event|									# LISTMOD Command
	PList.list(event)
	return nil
end

#==================================================
