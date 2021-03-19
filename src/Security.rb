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
# Security and permissions functions
#====================================================================================================

def valid_json?(json)				# Detect if a file is valid JSON
	buff = JSON.parse(json)
	return buff
rescue JSON::ParserError
	return nil
end

def update_json(file, data)			# Abstraction for updaating a JSON file
	File.open(file, 'w+') {|f| f.write(JSON.generate(data)) }
end

def action(mention, event, action)									# ACTION Handler method
	mention = event.user.name if (mention.empty?)						# If the target of the action is empty, then assume the user is targeting themself
	userTmp = Parser.get_user(mention, event)							# Parse the target name and get back a formatted mention
	line = (userTmp != nil && userTmp.id == event.user.id)? rand(3) : rand(IO.readlines("./ext/#{action}.action").size-3)+3
	target = (userTmp.nil?)? mention.join(" ") : userTmp.mention
 	return event.channel.send_embed do |embed|																# Send the embedded action
		embed.description = "**<@#{event.user.id}>** " + eval(IO.readlines("./ext/#{action}.action")[line])	# Pick a random string
		embed.color = EMBED_MSG_COLOR
	end
end

def embed_error(message, channel)
	channel.send_embed do |embed|
		embed.title = "Error"
		embed.description = message
		embed.color = EMBED_ERROR_COLOR
	end
end

def channel_get_name(chan)
	if (chan.is_a?(Discordrb::Channel)) then return chan.name end
	if $bot.channel(chan.to_i).nil? then return "<NO CHANNEL>" end
	return $bot.channel(chan.to_i).name
end

def server_get_name(srv)
	if (srv.is_a?(Discordrb::Server)) then return srv.name end
	if Parser.get_server(srv).nil? then return "<NO SERVER>" end
	return Parser.get_server(srv).name
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
	array.each.with_index { |str, index| (index == 0)? ret << str : ret << ", #{str}" }
	return ret
end

def generate_uniqe_name(file_type)
	charset = Array('A'..'Z') + Array('a'..'z')
	rndstr = Array.new(10) { charset.sample }.join	# If a file with this name already exists, then loop until we get a uniqe name
	rndstr = Array.new(10) { charset.sample }.join while (File.file?("#{rndstr}.#{file_type}"))
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
		return @@permits.fetch(user.to_s, nil) != nil											# If the user is in the permits, then return true
	end
	def query(user, level)																		# QUERY method. Checks if a user is a specific access level (0 = none, 1=usage, 2=admin)
		return @@permits.fetch(user.to_s, 0) >= level.to_i										# Check the user's access level and return false if not equal
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

module Parser							# PARSE module for parsing user names and nicknames
	module_function
	def get_user(user, event=nil)
		user = user.join(' ') if user.is_a?(Array)
		user = user.downcase

		if (event != nil && event.is_a?(Discordrb::Events::Event)) then memberList = event.server.members
		else memberList = $bot.servers.values.collect_concat {|srv| srv.members} end
		return $bot.parse_mention(user, event.server) if user.start_with?("<")
		return memberList.detect {|x| x.username.downcase.include?(user) || x.display_name.downcase.include?(user)}
	end
	def get_server(server)					# GET_SERVER method. Inputs a partial server name and returns the server object
		return nil if server.nil?
		server = server.to_s.downcase

		if (server.is_a?(Fixnum)) then return $bot.servers.values.detect {|srv| srv.id.include?(server)}
		else return $bot.servers.values.detect {|srv| srv.name.downcase.include?(server)} end
	end
	def get_channel(channel, server=nil)	# GET_CHANNEL method. Inputs a partial channel name and returns the channel object
		return nil if channel.nil?
		channel = channel.join(' ') if channel.is_a?(Array)
		channel = channel.downcase

		if (server != nil && server.is_a?(Discordrb::Server)) then channelList = server.channels
		else channelList = $bot.servers.values.collect_concat {|srv| srv.channels} end
		if (channel.to_i >= 100000000000000000) then return $bot.parse_mention("<\##{channel}>", server)
		else return channelList.detect {|x| x.name.downcase.include?(channel)} end
	end
end

class Setting													# SETTING class for storing persistent data
	def initialize()
		@@persistent = {}											# Create a new empty array to house the settings
		File.open("./ext/sys/persistent", 'w+') {|f| f.write(JSON.generate(@@persistent)) } unless valid_json?(IO.read("./ext/sys/persistent"))
		@@persistent = JSON.load IO.read("./ext/sys/persistent")	# If the persistence file is not valid JSON (could be empty) then generate a new JSON enclosure and write it out
	end
	def save(name, val)												# SAVE method. saves a piece of data with a name
		@@persistent.store(name, val)								# Store the data itself
		update_json("./ext/sys/persistent", @@persistent)			# Update the JSON file
		return true													# Return the all-good
	end
	def get(name)													# GET method. returns the data piece associated with a name, or nil if DNE
		ret = @@persistent.fetch(name, nil)							# Attempt to fetch the value
		return ret if (ret != nil)									# if its nil, then return nil
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
	attr_reader :e621_black_tags

	@e621_black_tags = []
	@config_name = ""
	def initialize(sys_config, strname)
		@config_name = strname
		 @e621_black_tags = sys_config.get(@config_name) if (sys_config.get(@config_name) != nil)
	end

	def e621_append_blacklist(tags)
		tags.each {|x| @e621_black_tags.push(x) if (!@e621_black_tags.include?(x))}
		Config.save(@config_name, @e621_black_tags)
		return nil
	end

	def e621_purge_blacklist(tags)
		tags.each {|x| @e621_black_tags.delete(x) if (@e621_black_tags.include?(x))}
		Config.save(@config_name, @e621_black_tags)
		return nil
	end

	def e621_screen_tags(tags)
		ret = []
		tags.each {|x| ret.push(x) if (@e621_black_tags.include?(x))}
		return ret
	end
end

class CommandHistory
	attr_accessor :line_buffer
	attr_reader :index, :max

	@index = 0
	def initialize(max_size=50)
		@max = max_size
		@hist = Array.new(1) { "" }
		self.update_index
	end
	def append(line)
		self.update_index
		@hist[@index] = line
		@hist.push("")
		self.trim if (@hist.length > @max)	# Keep a maximum of 50 lines in the history
		self.update_index
	end
	def up() @index = (@index > 0)? @index - 1 : @index end
	def down() @index = (@index < @hist.length - 1)? @index + 1 : @index end
	def peek() return @hist[@index] end

	private
	def trim() @hist.shift end
	def update_index()
		@index = @hist.length - 1
		@line_buffer = @hist[@index]
	end
end

#====================================================================================================

def require_nsfw(event)
	unless (event.channel.nsfw?)
		return event.send_embed do |embed|
			embed.title = "```Use this command in an NSFW marked channel.```"
			embed.color = EMBED_MSG_COLOR
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
			embed.color = EMBED_MSG_COLOR
		end
	end
end

#====================================================================================================
