
#==================================================
#     KhajiitBot  --  NotArtyom  --  03/06/18
#==================================================
#       Security and permissions functions
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
	if (target == nil || target == "<@!"+event.user.id.to_s+">") then line = rand(3) else line = rand(IO.readlines("./ext/#{action}").size-3)+3 end		# If the target exists then get the number of lines in the string file
	event.channel.send_embed do |embed|																		# Send the embedded action
		embed.description = "**<@#{event.user.id}>** " + eval(IO.readlines("./ext/#{action}")[line])		# Pick a random string and return it
		embed.color = 0xa21a5d
	end
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
		return user[0] + ">"	# im sorry
	end
	def get_uid(user, event) 																	# GET_UID method. Inputs a mention and returns an ID
		unless user[0] == "<"
			tmp = event.server.members.detect{|member| member.display_name.include?(user)}
			if tmp == nil then tmp = event.server.members.detect{|member| member.username.include?(user)}								# Return the ID int if the nickname exists
				if tmp == nil then tmp = event.server.members.detect{|member| member.username.downcase.include?(user.downcase)}			# Return the ID int if the username exists
					if tmp == nil then event.respond "Could not find user."; return nil end												# Return the ID int if the username exists. case insensetive
				end
			end
			return tmp.id
		end
		return user.delete('^0-9').to_i															# If the input is a ID w/ markup then strip the markup and return
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
	def self.load_tmp(event)
		if File.file?("./tmp*") then
			puts "[!!!] Fault. TMP image file already exists."
			return nil
		end
		files = event.message.attachments
		download = open(files[0].url)
		tmp = "./tmp" + files[0].filename.slice!(/\..*/)
		IO.copy_stream(download, tmp)
		img = Magick::Image::read(tmp)[0]
		return img
	end
	def self.return_img(event, image)
		if File.file?("./" + image.filename) then
			image.write("./" + image.filename)
			tmp = File.open("./" + image.filename)
			event.send_file(tmp)
			File.delete("./" + image.filename)
			tmp.close unless tmp.nil? or tmp.closed?
			return true
		else
			puts "[!!!] Fault. TMP image file not found before return."
			return nil
		end
	end
	def self.clense_percent(val)		# Changes val to be absolute. Returns true if increase, false if decrease
		if level < 100 then
			level = 100 - level
			return false
		else
			level = level - 100
			return true
		end
	end
	def self.contrast(event, level)
		image = load_tmp(event)
		if level >= 100 then
			level = level - 100
			image = image.sigmoidal_contrast_channel((level/2), Magick::QuantumRange.to_f * 0.50, true, Magick::AllChannels)
		else
			level = 100 - level
			image = image.sigmoidal_contrast_channel((level/2), Magick::QuantumRange.to_f * 0.50, false, Magick::AllChannels)
		end
		return_img(event, image)
		return nil
	end
	def self.modulate(event, level, op)
		image = load_tmp(event)
		if op == "hue" then
			image = image.colorize(0.60, 0.60, 0.60, Magick::Pixel.from_hsla(level, 100.0, 100.0, 1.0))
			image = image.sigmoidal_contrast_channel(10.0, Magick::QuantumRange.to_f * 0.50, true, Magick::AllChannels)
		elsif op == "saturation"
			image = image.modulate(1, (level/100)*2, 1)
		elsif op == "brightness"
			if level >= 100 then
				level = level.to_f - 100.0
				image = image.level(0.0 - (Magick::QuantumRange.to_f*((level/25.0))), Magick::QuantumRange, 1.0)
			else
				level = 100.0 - level.to_f
				image = image.level(0.0, Magick::QuantumRange.to_f * (1.0+(level/16)), 1.0)
			end
		end
		return_img(event, image)
		return nil
	end
	def self.rotate(event, degrees)
		image = load_tmp(event)
		image = image.rotate(degrees)
		return_img(event, image)
		return nil
	end
	def self.bw(event)
		image = load_tmp(event)
		image = image.quantize(256, Magick::GRAYColorspace)
		return_img(event, image)
		return nil
	end
	def self.invert(event)
		image = load_tmp(event)
		image = image.negate(false)
		return_img(event, image)
		return nil
	end
	def self.enhance(event)
		image = load_tmp(event)
		image = image.enhance()
		return_img(event, image)
		return nil
	end
	def self.sharpen(event, level)
		image = load_tmp(event)
		image = image.sharpen(4, level/20)
		return_img(event, image)
		return nil
	end
	def self.noise(event)
		image = load_tmp(event)
		tmpImg = Magick::Image.new(image.columns, image.rows)
		tmpImg.color_reset!("black")
		tmpImg = tmpImg.add_noise(Magick::ImpulseNoise)
		tmpImg = tmpImg.transparent("black", Magick::TransparentOpacity)
		tmpImg = tmpImg.modulate(1, 0.5, 1)
		tmpImg = tmpImg.blur_image(0.0, 1.0)

		image.composite!(tmpImg, Magick::CenterGravity, Magick::OverCompositeOp)
		return_img(event, image)
		return nil
	end
	def self.spread(event, level)
		image = load_tmp(event)
		image = image.spread(level)
		return_img(event, image)
		return nil
	end
	def self.dither(event, colors)
		image = load_tmp(event)
		tmpImg =
		if level % 2 == 0 then
			image = image.remap(image, Magick::RiemersmaDitherMethod)
		else
			image = image.remap(image, Magick::FloydSteinbergDitherMethod)
		end
		return_img(event, image)
		return nil
	end
end

#==================================================
