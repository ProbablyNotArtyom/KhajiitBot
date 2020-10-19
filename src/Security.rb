#
# MIT License
#
# Copyright (c) 2020 Carson Herrington
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
# KhajiitBot - NotArtyom - 2020
# ----------------------------------------
# Security and permissions functions
#====================================================================================================

def valid_json?(json)				# Detect if a file is valid JSON
	buff = JSON.parse(json)
		return buff
	rescue JSON::ParserError => e
		return nil
end

def update_json(file, data)			# Abstraction for updaating a JSON file
	File.open(file, 'w+') {|f| f.write(JSON.generate(data)) }
end

def action(target, event, action)																			# ACTION Handler method
	target = Parser.get_target(target, event)																# Parse the target name and get back a formatted ID
	if (target == nil || target == "<@!"+event.user.id.to_s+">") then line = rand(3) else line = rand(IO.readlines("./ext/#{action}.action").size-3)+3 end		# If the target exists then get the number of lines in the string file
	event.channel.send_embed do |embed|																		# Send the embedded action
		embed.description = "**<@#{event.user.id}>** " + eval(IO.readlines("./ext/#{action}.action")[line])	# Pick a random string
		embed.color = EMBED_COLOR
	end
	return nil
end

def channel_get_name(chan)
	if $bot.channel(chan.to_i).nil? then return "" end
	return $bot.channel(chan.to_i).name
end

def get_file_input(event)
	if (event.message.attachments.empty?) then
		chan_hist = event.channel.history(50)
		chan_hist.each do |msg|
			if (!msg.attachments.empty?) then
				debug_puts(msg.attachments[0].url)
				return msg.attachments[0].url
			elsif (!msg.embeds.empty?)
				debug_puts(msg.embeds[0].url)
				return msg.embeds[0].url
			end
		end
	else
		debug_puts(event.message.attachments[0].url)
		return event.message.attachments[0].url
	end
end

def a_get_list(array)
	ret = ""
	array.each.with_index do |str, index|
		if (index == 0) then
			ret << str
		else
			ret << ", #{str}"
		end
	end
	return ret
end

def generate_uniqe_name(file_type)
  charset = Array('A'..'Z') + Array('a'..'z')
  rndstr = Array.new(10) { charset.sample }.join
  # If a file with this name already exists, then loop until we get a uniqe name
  while (File.file?("#{rndstr}.#{file_type}"))
	  rndstr = Array.new(10) { charset.sample }.join
  end
  return "#{rndstr}.#{file_type}"
end

class Permit																		# Permit checking class
	def initialize()
		@@permits = {}																			# Create a new empty array to house out permits
		unless valid_json?(IO.read("./ext/sys/permissions")) then  File.open("./ext/sys/permissions", 'w+') {|f| f.write(JSON.generate(@@permits)) } end
																								# If the Permit file is not valid JSON (could be empty) then generate a new JSON enclosure and write it out
		@@permits = JSON.load IO.read("./ext/sys/permissions")									# If it is valid, then load the saved permits into the array
		return
	end

	def add(user, level)																		# ADD method. Adds a user to the permits
		@@permits.store(user.to_s, level.to_i)													# add the ID to the permits array
		update_json("./ext/sys/permissions", @@permits)											# Update the saved permits
		return true
	end
	def is_exist(user)																			# IS_EXIST method. Checks if a user is in the permits
		if @@permits.fetch(user.to_s, nil) == nil then return false end							# If the user is in the permits, then return true
		return true
	end
	def query(user, level)																		# QUERY method. Checks if a user is a specific access level (0 = none, 1=usage, 2=admin)
		if @@permits.fetch(user.to_s, 0) >= level.to_i then return true else return false end	# Check the user's access level and return false if not equal
	end
	def list(svevent)																			# LIST method. Lists the current permits
		i = 0
		out = ""																				# Setup list buffer
		userlist = svevent.server.members														# Get the member arrays of all members
		userlist.map! {|x| x.id.to_s}															# Convert the uID ints to strings
		while i < userlist.length
			x = 0
			until userlist[i] == @@permits.keys[x] && x < @@permits.length do x += 1 end		# As long as X < the number of permits, check the permits to see if the user is present
			mempt = svevent.server.member(@@permits.keys[i])									# Get the member's method
			out << mempt.username + "  -  " + @@permits.fetch(mempt.id.to_s, 0).to_s + "\n"		# Shift their username into the output buffer
			i += 1																				# Repeat
		end
		svevent.respond out																		# Respond with the buffer
		return nil
	end
end

class Parse																			# PARSE class for parsing user names and nicknames
	def initialize()
	end
	def get_user(user)																		# GET_USER method. inputs a nickname or username and returns a user object
		if user == nil then return nil end													# If user is nil then abort
		if user.length > 1 then return user.join(" ") end
		unless user[0] == "<"																# As long as the username isn't an ID then loop
			serverList = $bot.servers
			serverList.each_value {|srv|
				tmp = srv.members.detect{|member| member.display_name.include?(user)}											# Return the ID string if the user matches a nickname in the server
				if tmp == nil then tmp = srv.members.detect{|member| member.display_name.downcase.include?(user.downcase)}		# Return the ID string if the user matches a nickname in the server. Case insensetive
					if tmp == nil then tmp = srv.members.detect{|member| member.username.include?(user)}						# Return the ID string if the user matches a username in the server
						if tmp == nil then tmp = srv.members.detect{|member| member.username.downcase.include?(user.downcase)}	# Return the ID string if the user matches a username in the server. Case insensetive															# Return nil if no matches
						end
					end
				end
				if tmp != nil then return tmp end
			}
			return nil
		end
		return nil
	end
	def get_server(server)
		if server[0] == nil then return nil end													# If user is nil then abort
		unless server[0][0] == "<"																# As long as the username isn't an ID then loop
			serverList = $bot.servers
			serverList.each_value {|srv|
				if srv.name.include?(server) then return srv end
			}
			return nil
		end
		return server[0]
	end
	def get_target(user, event)																	# GET_TARGET method. inputs a nickname or username and returns a uID
		if user[0] == nil then return nil end													# If user is nil then abort
		if user.length > 1 then return user.join(" ") end										# If the username is longer than 1 word then join them w/ spaces
		unless user[0][0] == "<"																# As long as the username isn't an ID then loop
			tmp = event.server.members.detect{|member| member.display_name.include?(user[0])}											# Return the ID string if the user matches a nickname in the server
			if tmp == nil then tmp = event.server.members.detect{|member| member.display_name.downcase.include?(user[0].downcase)}		# Return the ID string if the user matches a nickname in the server. Case insensetive
				if tmp == nil then tmp = event.server.members.detect{|member| member.username.include?(user[0])}						# Return the ID string if the user matches a username in the server
					if tmp == nil then tmp = event.server.members.detect{|member| member.username.downcase.include?(user[0].downcase)}	# Return the ID string if the user matches a username in the server. Case insensetive
						if tmp == nil then return user.join(" ") end																	# Return nil if no matches
					end
					if tmp.id == event.user.id then return nil end
					return "<@" + tmp.id.to_s + ">"												# Username markup
				end
			end
			if tmp.id == event.user.id then return nil end
			return "<@!" + tmp.id.to_s + ">"													# Nickname markup
		end
		return user[0]
	end
	def get_uid(user, event) 																	# GET_UID method. Inputs a mention and returns an ID
		unless user[0] == "<"
			tmp = event.server.members.detect{|member| member.display_name.include?(user)}
			if tmp == nil then tmp = event.server.members.detect{|member| member.username.include?(user)}								# Return the ID int if the nickname exists
				if tmp == nil then tmp = event.server.members.detect{|member| member.username.downcase.include?(user.downcase)}			# Return the ID int if the username exists
					if tmp == nil then tmp = event.server.members.detect{|member| member.display_name.downcase.include?(user.downcase)}	# Return the ID int if the username exists. case insensetive
						if tmp == nil then return nil end
					end
				end
			end
			return tmp.id
		end
		return user.delete('^0-9').to_i															# If the input is a ID w/ markup then strip the markup and return
	end
	def get_user_obj(user, event)
		if user == nil then return nil end
		unless user[0] == "<"
			tmp = event.server.members.detect{|member| member.display_name.include?(user)}
			if tmp == nil then tmp = event.server.members.detect{|member| member.username.include?(user)}
				if tmp == nil then tmp = event.server.members.detect{|member| member.username.downcase.include?(user.downcase)}
					if tmp == nil then tmp = event.server.members.detect{|member| member.display_name.downcase.include?(user.downcase)}
						if tmp == nil then return nil end
					end
				end
			end
			return tmp
		else
			return $bot.parse_mention(user, event.server)
		end
	end
end

class Setting																		# SETTING class for storing persistent data
	def initialize()
		@@persistent = {}																		# Create a new empty array to house the settings
		unless valid_json?(IO.read("./ext/sys/persistent")) then  File.open("./ext/sys/persistent", 'w+') {|f| f.write(JSON.generate(@@persistent)) } end
																								# If the persistence file is not valid JSON (could be empty) then generate a new JSON enclosure and write it out
		@@persistent = JSON.load IO.read("./ext/sys/persistent")
	end
	def save(name, val)																			# SAVE method. saves a piece of data with a name
		@@persistent.store(name, val)															# Store the data itself
		update_json("./ext/sys/persistent", @@persistent)										# Update the JSON file
		return true																				# Return the all-good
	end
	def get(name)																				# GET method. returns the data piece associated with a name, or nil if DNE
		ret = @@persistent.fetch(name, nil)														# Attempt to fetch the value
		unless ret == nil; return ret end														# if its nil, then return nil
	end
end

class ImageMod
	def self.load_tmp(*event)
		files = get_file_input(event[0])
		img = MiniMagick::Image.open(files)
		return img
	end
	def self.return_img(event, image)
		filname = generate_uniqe_name(image.type)
		image.write(filname)
		tmp = File.open(filname, 'r')
		event.send_file(tmp)
		File.delete(filname)
		tmp.close unless tmp.nil? or tmp.closed?
	end
	def self.write_img(image)
		filname = generate_uniqe_name(image.type)
		image.write(filname)
		return filname
	end
	def self.remove_img(filname)
		File.delete(filname)
	end
	def self.compose_gif(event, images, image, frameTime)
		if File.file?("./" + image.filename) then
			images.delay = frameTime
			filname = generate_uniqe_name(image.type)
			image.write(filname)
			tmp = File.open(filname, 'r')
			event.send_file(tmp)
			File.delete(filname)
			tmp.close unless tmp.nil? or tmp.closed?
			return true
		else
			puts "[!!!] Fault. TMP image file not found before return."
			return nil
		end
	end
end

class E621_blacklist
	@e621_black_tags = []
	@config_name = ""
	def initialize(sys_config, strname)
		@config_name = strname
		if (sys_config.get(@config_name) != nil) then
			@e621_black_tags = sys_config.get(@config_name)
		end
	end
	def e621_get_blacklist()
		return @e621_black_tags
	end

	def e621_append_blacklist(tags)
		tags.each do |tag|
			if (!@e621_black_tags.include?(tag)) then
				@e621_black_tags.push(tag)
			end
		end
		Config.save(@config_name, @e621_black_tags)
		return nil
	end

	def e621_purge_blacklist(tags)
		tags.each do |tag|
			if (@e621_black_tags.include?(tag)) then
				@e621_black_tags.delete(tag)
			end
		end
		Config.save(@config_name, @e621_black_tags)
		return nil
	end

	def e621_screen_tags(tags)
		ret = []
		tags.each do |tag|
			if (@e621_black_tags.include?(tag)) then
				ret.push(tag)
			end
		end
		return ret
	end
end

#====================================================================================================

module Urban
	extend self

	# Gets the definitions for the word.
	# @param word [String] The word to define.
	# @return [Array<Slang>] An array of #{Slang} objects.
	def define(word)
		params = { term: word }
		@client = HTTPClient.new if @client.nil?
		response = JSON.parse(@client.get(URI.parse('http://api.urbandictionary.com/v0/define'), params).body)
		ret = []

		response['list'].each do |hash|
			ret << Slang.new(hash)
		end
		return ret
	end
end

#====================================================================================================

def require_nsfw(event)
	unless (event.channel.nsfw?)
		return event.send_embed do |embed|
			embed.title = "```Use this command in an NSFW marked channel.```"
			embed.color = EMBED_COLOR
		end
	end
end

def require_blacklist(event, post, blacklist)
	taglist = []
	post['tags'].each_value { |x| taglist = taglist + x }					# Create a flat array of all tags on the post
	black_ret = blacklist.e621_screen_tags(taglist)							# Check the blacklist
	unless (black_ret.empty?)
		return event.send_embed do |embed|
			embed.title = "Error"
			embed.description = "Post contained one or more blacklisted tags: **#{a_get_list(black_ret)}**"
			embed.color = EMBED_COLOR
		end
	end
end

#====================================================================================================
