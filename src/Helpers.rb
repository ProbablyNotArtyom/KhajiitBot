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
# Various classes and functions designed to streamlign development elseswhere
#====================================================================================================

# Detect if a file is valid JSON
def valid_json?(json)				
	buff = JSON.parse(json)
	return buff
rescue JSON::ParserError
	return nil
end

# Abstraction for updating a JSON file
def update_json(file, data)			
	File.open(file, 'w+') { |f| f.write(JSON.generate(data)) }
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

# Get the link to the last file posted within the current channel
def get_file_input(event)
	if (event.message.attachments.empty?)
		chan_hist = event.channel.history(50)
		chan_hist.each do |msg|
			if (!msg.attachments.empty?)
				DEBUG_PUTS(msg.attachments[0].url)
				return msg.attachments[0].url
			elsif (!msg.embeds.empty?)
				DEBUG_PUTS(msg.embeds[0].url)
				return msg.embeds[0].url
			end
		end
	else
		DEBUG_PUTS(event.message.attachments[0].url)
		return event.message.attachments[0].url
	end
	return nil
end

# Generates a filename that is hopefully uniqe
def generate_uniqe_name(file_type)
	charset = Array('A'..'Z') + Array('a'..'z')
	rndstr = Array.new(10) { charset.sample }.join	# If a file with this name already exists, then loop until we get a uniqe name
	rndstr = Array.new(10) { charset.sample }.join while (File.file?("#{rndstr}.#{file_type}"))
	return "#{rndstr}.#{file_type}"
end

# Error if not in an NSFW channel
def require_nsfw(event)
	unless (event.channel.nsfw?)
		return event.send_embed do |embed|
			embed.title = "Error"
			embed.title = "Use this command in an NSFW marked channel."
			embed.color = EMBED_ERROR_COLOR
		end
	end
end

#====================================================================================================

# Parse: parses user names and nicknames
module Parser
	extend self
	
	# GET_USER: Inputs a partial username and a message event. returns a user object
	def get_user(user, event=nil)
		return nil if user.nil?
		return nil if (user.is_a?(Array) && user.length == 0)	# Idiot guard
		user = user.join(' ') if user.is_a?(Array)				# Stringify
		user = user.downcase									# Ensure lowercase so we can ignore case when matching

		if (event != nil && event.is_a?(Discordrb::Events::Event)) then memberList = event.server.members
		else memberList = $bot.servers.values.collect_concat { |srv| srv.members } end
		return $bot.parse_mention(user, event.server) if user.start_with?("<")
		return memberList.detect { |x| x.username.downcase.include?(user) || x.display_name.downcase.include?(user) }
	end
	
	# GET_SERVER: Inputs a partial server name. returns the server object
	def get_server(server)
		return nil if server.nil?
		return server if (server.is_a?(Discordrb::Server))		# Idiot guard

		if (server.is_a?(Integer)) then return $bot.servers.values.detect { |srv| srv.id == server }
		else return $bot.servers.values.detect { |srv| srv.name.downcase.include?(server.to_s.downcase) } end
	end
	
	# GET_CHANNEL: Inputs a partial channel name and a server object. returns the channel object
	def get_channel(channel, server=nil)
		return nil if channel.nil?
		return channel if (channel.is_a?(Discordrb::Channel))	# Idiot guard
		channel = channel.join(' ') if channel.is_a?(Array)		# Stringify

		if (server != nil && server.is_a?(Discordrb::Server)) then channelList = server.channels
		elsif (server != nil && server.is_a?(Integer)) then channelList = get_server(server).channels
		else channelList = $bot.servers.values.collect_concat { |srv| srv.channels } end

		if (channel.to_i >= 100000000000000000) then return $bot.parse_mention("<\##{channel}>", server)
		else return channelList.detect { |x| x.name.downcase.include?(channel) } end
	end

	# GET_EMOJI: Inputs a full emoji name. returns the emoji object
	def get_emoji(emoji)
		return nil if emoji.nil?
		return emoji if (emoji.is_a?(Discordrb::Emoji))			# Idiot guard
		emoji = emoji.join(' ') if emoji.is_a?(Array)			# Stringify
		emoji = emoji.downcase									# Ensure lowercase so we can ignore case when matching

		emojilist = []
		$bot.servers.values.each { |x| emojilist += x.emoji.values }

		return emojilist.detect { |x| x.name == emoji }
		return nil
	end
	
	public :get_user
	public :get_server
	public :get_channel
	public :get_emoji
end

# Setting: stores persistent data
class Setting
	def initialize()
		@@persistent = {}											# Create a new empty array to store the settings
		File.open("./ext/sys/persistent", 'w+') {					# If the persistence file is not valid JSON (could be empty) then generate a new JSON enclosure and write it out
			|f| f.write(JSON.generate(@@persistent))
		} unless valid_json?(IO.read("./ext/sys/persistent"))
		@@persistent = JSON.load IO.read("./ext/sys/persistent")
	end

	# SAVE: saves a piece of data with a name
	def save(name, val)
		@@persistent.store(name, val)								# Store the data itself
		update_json("./ext/sys/persistent", @@persistent)			# Update the JSON file
		return true													# Return the all-good
	end

	# GET: returns the data piece associated with a name, or nil if DNE
	def get(name)
		ret = @@persistent.fetch(name, nil)							# Attempt to fetch the value
		return ret if (ret != nil)									# if its nil, then return nil
	end

	public :initialize
	public :save
	public :get
end

#ImageMod: filesystem utilities for managing images
module ImageMod
	extend self
	
	# LOAD_TMP: opens an event's attached iamge
	def load_tmp(*event)
		files = get_file_input(event[0])
		img = MiniMagick::Image.open(files)
		return img
	end
	
	# RETURN_IMG: returns an image in response to an event descriptor
	def return_img(event, image)
		filename = generate_uniqe_name(image.type)
		image.write(filename)
		tmp = File.open(filename, 'r')
		event.send_file(tmp)
		File.delete(filename)
		tmp.close unless tmp.nil? or tmp.closed?
	end
	
	# WRITE_IMG: writes an image to a unique file
	def write_img(image)
		filename = generate_uniqe_name(image.type)
		image.write(filename)
		return filename
	end

	# REMOVE_IMG: removes an image file
	def remove_img(filename)
		File.delete(filename)
	end
	
	# COMPOSE_GIF: Turns an array of images into a GIF
	def compose_gif(event, images, image, frameTime)
		if File.file?("./" + image.filename) then
			images.delay = frameTime
			filename = generate_uniqe_name(image.type)
			image.write(filename)
			tmp = File.open(filename, 'r')
			event.send_file(tmp)
			File.delete(filename)
			tmp.close unless tmp.nil? or tmp.closed?
			return true
		else
			puts "[!!!] Fault. TMP image file not found before return."
			return nil
		end
	end

	public :load_tmp
	public :return_img
	public :write_img
	public :remove_img
	public :compose_gif
end

# TODO: Allow different servers to have different blacklists
#E621_blacklist: implements a tag blacklisting system for e621
class E621_blacklist
	attr_reader :e621_black_tags

	@e621_black_tags = []
	@config_name = ""
	
	# INITIALIZE: inputs the system Settings class and the blacklist's name
	def initialize(sys_config, strname)
		@config_name = strname
		@e621_black_tags = sys_config.get(@config_name) if (sys_config.get(@config_name) != nil)
	end
	
	# APPEND: adds new tags to the blacklist
	def append(tags)
		tags.each {|x| @e621_black_tags.push(x) if (!@e621_black_tags.include?(x))}
		Config.save(@config_name, @e621_black_tags)
		return nil
	end
	
	# REMOVE: removes a list of tags from the blacklist
	def remove(tags)
		tags.each {|x| @e621_black_tags.delete(x) if (@e621_black_tags.include?(x))}
		Config.save(@config_name, @e621_black_tags)
		return nil
	end
	
	# CLEAR: clears the blacklist
	def clear()
		@e621_black_tags = []
		Config.save(@config_name, @e621_black_tags)
		return nil
	end
	
	# CHECK_TAGS: checks an input for any blacklisted tags and returns any found
	def check_tags(tags)
		ret = []
		tags.each {|x| ret.push(x) if (@e621_black_tags.include?(x))}
		return ret
	end
	
	public :initialize
	public :append
	public :remove
	public :clear
	public :check_tags
end

# CommandHistory: Implements a list meant to be used for a command history
class CommandHistory
	attr_accessor :line_buffer
	attr_reader :index, :max

	@index = 0
	@line_buffer = ""
	def initialize(max_size=50)
		@max = max_size
		@hist = Array.new(1) { "" }
		self.update_index
	end

	# APPEND: adds a new entry to the history list
	def append(line)
		self.update_index
		@hist[@index] = line
		@hist.push("")
		self.trim if (@hist.length > @max)
		self.update_index
	end

	# UP: moves current entry index up
	def up() @index = (@index > 0)? @index - 1 : @index end

	# DOWN: moves current entry index down
	def down() @index = (@index < @hist.length - 1)? @index + 1 : @index end

	# PEEK: returns the value of the current history index
	def peek() return @hist[@index] end

	# TRIM: remove the topmost line of the list
	def trim() @hist.shift end

	# UPDATE_INDEX: recalculate and update accessors
	def update_index()
		@index = @hist.length - 1
		@line_buffer = @hist[@index]
	end
	
	public :initialize
	public :append
	public :up
	public :down
	public :peek
	
	private :trim
	private :update_index
end

#====================================================================================================
