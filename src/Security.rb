
#==================================================
#     KhajiitBot  --  NotArtyom  --  03/06/18
#==================================================
#       Security and permissions functions
#==================================================
#
# MIT License
# 
# Copyright (c) [year] [fullname]
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
	if Blacklist::new.query(event.user.id, action) then return nil end										# Check the blacklist and return nil if the user is blacklisted from the command
	target = Parse::new.get_target(target, event)															# Parse the target name and get back a formatted ID
	if target == nil then line = rand(3) else line = rand(IO.readlines("./ext/#{action}").size-3)+3 end		# If the target exists then get the number of lines in the string file
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

class Blacklist																		# Blacklist class
	def initialize()
		@@blacklist = {}																		# Create new empty array to store our blacklist
		unless valid_json?(IO.read("./ext/sys/blacklist")) then  File.open("./ext/sys/blacklist", 'w+') {|f| f.write(JSON.generate(@@blacklist)) } end
																								# If the Blacklist file is not valid JSON (could be empty) then generate a new JSON enclosure and write it out
		@@blacklist = JSON.load IO.read("./ext/sys/blacklist")									# If it is valid, then load the saved blacklist into the array
		return
	end
	def add(user, command)																		# ADD method. adds a user to the blacklist				
		unless @@blacklist.key?(command) then @@blacklist[command] = Array.new() end			# If the blacklist doesn't have an entry for this command, add one
		if @@blacklist[command].include?(user) then return nil end								# If the user is already there than return nil
		@@blacklist[command] << user															# Shift the user into the new entry
		update_json("./ext/sys/blacklist", @@blacklist)											# Save the blacklist
		return true
	end
	def purge(user, command)																	# PURGE method. removes a user from the blacklist
		unless @@blacklist.key?(command) then return nil end									# If the command doesn't exist then return nil
		unless @@blacklist[command].include?(user) then return nil end							# If the user doesn't exist then return nil
		@@blacklist[command].delete(user)														# Remove the user entry
		update_json("./ext/sys/blacklist", @@blacklist)											# Update the blacklist
		return true
	end
	def query(user, command)																	# QUERY method. checks if the user is blacklisted from a command
		unless @@blacklist.key?(command) then return nil end									# If the command doesn't exist then return nil
		if @@blacklist[command].include?(user) then return true end								# If the user doesn't exist then return true
		return nil
	end
	def list(event, target)																		# LIST method. lists the blacklisted users for a command
		unless target == nil																	# If the target is nil than ignore everything
			users = @@blacklist[target].map {|uid| event.server.member(uid).username}			# get an array of all users for a command
			event.respond "k.#{target}:\n    #{users.join("\n    ")}"							# Return the user array
			return nil
		end
		event.respond "Must specify command."													# Respond if a command is invalid
		return nil
	end
end

class NSFW																			# NSFW class.
	def initialize()
		@@nsfwlist = {}																			# Create new empty array to store our list
		unless valid_json?(IO.read("./ext/sys/nsfw")) then  File.open("./ext/sys/nsfw", 'w+') {|f| f.write(JSON.generate(@@nsfwlist)) } end
																								# If the list file is not valid JSON (could be empty) then generate a new JSON enclosure and write it out
		@@nsfwlist = JSON.load IO.read("./ext/sys/nsfw")										# If it is valid, then load the saved list into the array
		return
	end
	def add(channel)																			# ADD method. adds a user to the list
		if @@nsfwlist.key?(channel) then return nil end											# If the channel is in the list already then return nil
		@@nsfwlist[channel] = 0																	# Set the channel as enabled
		update_json("./ext/sys/nsfw", @@nsfwlist)												# Save the channel list
		return true
	end
	def purge(channel)																			# PURGE method. removes a channel from the list
		unless @@nsfwlist.key?(channel) then return nil end										# If the channel isn't there then return nil
		@@nsfwlist.delete(channel)																# Purge the channel
		update_json("./ext/sys/nsfw", @@nsfwlist)												# Save the channel list
		return true
	end
	def query(channel)																			# QUERY method. checks if a channel is on the allowed list
		unless @@nsfwlist.key?(channel) then return nil end										# Check if its there and return nil of not
		return true
	end
end

class Parse																			# PARSE class for parsing user names and nicknames 
	def initialize()
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
					if tmp == nil then event.respond "Could not find user."; return nil end												# Return the ID int if the username exists. case insensetive
				end
			end
			return tmp.id
		end
		return user.delete('^0-9').to_i															# If the input is a ID w/ markup then strip the markup and return
	end
end


#==================================================
