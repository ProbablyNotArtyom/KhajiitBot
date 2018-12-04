
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

$bot.command :help do |event|					# Help command
	begin
		event.message.delete					# Delete the help in case somthing implodes
	rescue
	end
	event.channel.send_embed do |embed|			# Send embedded help message
		embed.thumbnail = Discordrb::Webhooks::EmbedImage.new(url: 'http://i.imgur.com/pG3L2RP.png')
		embed.description = 'Written by NotArtyom'
		embed.add_field(name: 'General commands:', value: "`k.help`  :  shows this help page.
`k.trade  [image]`  :  adds user image to meme pool and sends a random meme back.
`k.image`  :  gets a random image from the k.trade pool.
`k.lewd <image>`  :  adds user image to lewd pool and sends a random lewd back.
`k.arouse`  :  returns a random lewd from the pool.
`k.random <max>`  :  generates a truly random number with max value. default max is 10.
`k.8ball [question]`  :  answers any question with true randomness.
`k.rate @[user]`  :  rates another user on a scale from 0 to 10. slightly less random...
`k.katia`  :  returns a random katia image.")

		embed.add_field(name: 'Interaction commands:', value: "`k.yiff @[user]`  :  sends a yiffy message.
`k.hug @[user]`  :  hugs another user.
`k.kiss @[user]`  :  kisses another user.
`k.stab @[user]`  :  stabs another user.
`k.shoot @[user]`  :  shoots another user.
`k.pet @[user]`  :  pets another user.
`k.bless @[user]`  :  blesses another user.")

		embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: 'KhajiitBot', url: 'https://discordapp.com/oauth2/authorize?client_id=452660556990644225&scope=bot&permissions=0', icon_url: 'http://i.imgur.com/pG3L2RP.png')
		embed.color = 0xa21a5d
	end
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
	if max == nil then max = 10 end											# If the max is not specified, then use 10
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
		index = rand(1035).to_s
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

$bot.command :test do |event|
	event.channel.send_embed do |embed|
		embed.title = "Title Test!"										
		#embed.description = "Description Test!"
		embed.thumbnail = Discordrb::Webhooks::EmbedImage.new(url: 'http://i.imgur.com/pG3L2RP.png')
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
