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
# Internal command prompt
#====================================================================================================

class PilotInterface
	# Hardcoded values for positioning the TUI elements. Yes, i know its egregious
	
	HEAD_HEIGHT			= 1
	PROMPT_HEIGHT		= 3
	CHAT_OFFSET			= HEAD_HEIGHT + PROMPT_HEIGHT
	CLI_MARGINS			= 2		# Empty space on either side of the CLI text prompt
	CLI_ALLOWED_CHARS	=	('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a + 
							[" ", ":", "<", ">", "|", "#", "%", "^"] +
							["&", "@", "*", ",", "!", "?", ".", "-"] +
							["_", "=", "+", "[", "]", "(", ")", "{"] +
							["}", ";", "\'", "\"", "\\", "/", "`", "~"] +
							["\@", "$"]
			
	# Help message constant as to make its use later not a visual mess
	HELP_MESSAGE = "" +
		"go       | Change to a different channel. args: [channel id]\n" +
		"exit     | Exits KhajiitBot\n" +
		"status   | Sets KhajiitBot's activity state. args: ['online'|'idle'|'invisible']\n" +
		"play     | Sets the playing status. args: [string]\n" +
		"watch    | Sets the watching status. args: [string]\n" +
		"say      | Sends a text message to the current channel. args: [string]\n" +
		"embed    | Sends an embed message to the current channel. args: [string]\n" +
		"rm       | Removes the last sent message.\n" +
		"leave    | Leaves a server. args: [server id]\n" +
		"dm       | Direct messages a user. args: [user id][message]\n" +
		"uid      | Prints the ID of a user by name. args: [username]\n" +
		"sid      | Prints the ID of a server by name. args: [server name] \n" +
		"cid      | Prints the ID of a channel by name. args: [channel name] \n" +
		"servers  | Prints a list of servers KhajiitBot is in.\n" +
		"channels | Prints a list of all channels from every server KhajiitBot is in.\n" +
		"update   | Forces the command UI to be redrawn.\n" +
		"eval     | Evaluates ruby code. USED ONLY FOR DEBUGGING. args: [ruby code]"

	# Note: RuTui::Screen.size returns the size in the form [y,x], not [x,y]. wtf???
	
	# Initialize, with config_obj being the global Setting object
	def initialize(config_obj)
		# Update the chat text as discordrb detects new messages
		$bot.message() do |e|
			if (e.message.channel == @open_channel_id) then
				chat_puts(@kbcli, @screen, "#{e.message.author.display_name} : #{e.message.content}", 7)
			end
		end
		
		# Get current server/channel IDs used by last run if present
		@open_channel_id = (Parser.get_channel(config_obj.get("channel")))? config_obj.get("channel") : nil
		@open_server_id = (Parser.get_server(config_obj.get("server")))? config_obj.get("server") : nil
		
		# In the event that the saved channel is valid but the server isnt, set it to the channel's parent server
		if (@open_channel_id != nil && @open_server_id == nil)
			@open_server_id = Parser.get_channel(@open_channel_id).server.id
		end

		# Set the char/color used by different TUI widgets
		@pixel_chat = RuTui::Pixel.new(15, 0, " ")		# Char used by chat
		@pixel_head = RuTui::Pixel.new(15, 4, " ")		# Char used by header
		@pixel_cli = RuTui::Pixel.new(15, 4, " ")		# Char used by CLI

		# Init screen and set default char
		@kbcli = RuTui::Screen.new
		@kbcli.set_default(@pixel_chat)

		# Widget for chat area
		@box_chat = RuTui::Box.new({ :x => 0, :y => HEAD_HEIGHT, :width => RuTui::Screen.size[1], :height => RuTui::Screen.size[0]-CHAT_OFFSET })
		@box_chat.corner = @pixel_chat
		@box_chat.vertical = @pixel_chat
		@box_chat.horizontal = @pixel_chat
		@box_chat.fill = @pixel_chat
		@box_chat.create
		@kbcli.add(@box_chat)
		
		# Window header frame
		@box_head = RuTui::Line.new({ :x => 0, :y => 0, :length => RuTui::Screen.size[1], :direction => :horizontal })
		@box_head.pixel = @pixel_head
		@box_head.endpixel = @pixel_head
		@box_head.create
		@kbcli.add(@box_head)
		
		# Window header info text
		@text_head = RuTui::Text.new({ :x => 0, :y => 0, :text => tui_get_location(), :foreground => 15 })
		@text_head.pixel = @pixel_head
		@kbcli.add(@text_head)
		
		# CLI input frame
		@box_cli = RuTui::Box.new({ :x => 0, :y => RuTui::Screen.size[0]-PROMPT_HEIGHT, :width => RuTui::Screen.size[1], :height => PROMPT_HEIGHT })
		@box_cli.corner = @pixel_cli
		@box_cli.vertical = @pixel_cli
		@box_cli.horizontal = @pixel_cli
		@box_cli.fill = @pixel_cli
		@box_cli.create
		@kbcli.add(@box_cli)
		
		# CLI input field widget
		@cli_field = RuTui::Textfield.new({ :x => 1, :y => RuTui::Screen.size[0]-PROMPT_HEIGHT+1, :pixel => @pixel_cli, :focus_pixel => @pixel_cli })
		@cli_field.set_focus
		@cli_field.width = RuTui::Screen.size[1]-CLI_MARGINS
		@cli_field.allow = CLI_ALLOWED_CHARS
		@kbcli.add(@cli_field)
		
		@screen = init_chat(@kbcli)			# Init the text array used by the chat
		@size = RuTui::Screen.size			# Store unrefreshed screen size
		@HBuff = CommandHistory.new(50)		# Create object that handles cli command history

		# Add the constructed screen to the manager
		RuTui::ScreenManager.add(:default, @kbcli)	
	end
	
	# Cleans any unicode characters longer than 1 byte
	def clense(str)
		return str if (str.ascii_only?)		# Skip if no unicode present
		newstr = ""
		
		# Replace unicode chars with '?'
		str.each_char.with_index {|char, i| newstr[i] = (/[\x00-\x7F]/ =~ char)? str[i] : '?'}	
		return newstr
	end

	def new_textarray(array, diff, size)
		if (diff < 0) then 										# Screen shrank
			(0..(diff.abs-1)).each {|x| @kbcli.delete(array[x])}	# Prune the line widgets not visible from the screen
			array.shift(diff.abs)									# Remove the same lines from the array itself
			array.each {|line| line.move(0, diff)}					# Move each remaining widget up on the screen
		else													# Screen grew
			# Create new text widgets for each new line
			(0..(diff-1)).each do |x|								
				array.insert(x, RuTui::Text.new({ :x => 0, :y => HEAD_HEIGHT+x, :text => " ", :foreground => 15 }))
				array[x].max_width = size[1]
				array[x].pixel = @pixel_chat
			end
			
			# Move the old lines down on the screen
			(diff..(array.length-1)).each {|x| array[x].move(0, diff)}	
		end
		return array.each {|line| line.create}
	end

	def init_chat(screen)
		# Create array of text widgets, one for each line
		array = Array.new(RuTui::Screen.size[0]-CHAT_OFFSET) {
			RuTui::Text.new({ :x => 0, :y => HEAD_HEIGHT, :text => " ", :foreground => 15 })
		}
		
		# Configure each text line
		array.each_with_index do |index, x|
			index.set_position(0, HEAD_HEIGHT+x)
			index.max_width = RuTui::Screen.size[1]
			index.pixel = @pixel_chat
			screen.add(index)
		end
		return array
	end

	# Print string scrolling chat
	def chat_scroll(screen, array, string, color=15)
		# Split string into multiple lines based on the max lign length
		numLines = (string.size / RuTui::Screen.size[1])

		# For each new line, add it to the screen
		numLines.downto(0) do |x|
			screen.delete(array[x])
			array.push(RuTui::Text.new({ :x => 0, :y => RuTui::Screen.size[0]-PROMPT_HEIGHT-1-x, :text => string[0..RuTui::Screen.size[1]], :foreground => color }))
			string = string[RuTui::Screen.size[1]-1..-1]
			
			# Configure each new line
			array.last.max_width = RuTui::Screen.size[1]
			array.last.pixel = @pixel_chat
			array.last.create
			
			# Add it to the screen
			screen.add(array.last)
		end
		array.shift(numLines+1)
		(0..(array.length-numLines-2)).each {|i| array[i].move(0, -(numLines+1))} 	# ???
		RuTui::ScreenManager.draw
	end

	# Redraw the TUI while updating the layout to fit the current terminal window
	def tui_redraw()
		# Dont resize if we can't fit everything on the new screen
		return if RuTui::Screen.size[0] <= 5
		new_size = RuTui::Screen.size
		
		# Update widgets
		@box_head.length = new_size[1]
		@box_chat.width = new_size[1]
		@box_chat.height = new_size[0]-CHAT_OFFSET
		@text_head.max_width = new_size[1]
		@cli_field.width = new_size[1]-CLI_MARGINS
		@box_cli.width = new_size[1]
		
		# Move the CLI input field & frame to the new bottom of the screen
		@cli_field.move(0, new_size[0] - @size[0])	
		@box_cli.move(0, new_size[0] - @size[0])
		
		# Create a new line array
		@screen = new_textarray(@screen, new_size[0] - @size[0], @size)
	
		# Reinit the TUI widgets with their new positions
		@box_head.create
		@box_chat.create
		@box_cli.create

		# Update screen
		RuTui::ScreenManager.refit
		RuTui::ScreenManager.draw
		@size = new_size
	end

	# Get formatted string for TUI header
	def tui_get_location()
		srv = (Parser.get_server(@open_server_id))? Parser.get_server(@open_server_id).name : "NONE"		# Set channel name in header, or NONE if not set
		chan = (Parser.get_channel(@open_channel_id))? Parser.get_channel(@open_channel_id).name : "NONE"	# Set server name in header, or NONE if not set
		"Current channel: #{srv}/#{chan}"
	end

	# Prints a string to the chat, handling all internals like scrolling and widget placement
	def chat_puts(screen, array, string, color=nil)
		# Create a buffer that aligns the wrapped ligns vertically with the ':' seperator in the first line
		buffer = string[/^.+?(?=:)/]
		buffer = "" if (buffer.nil?)
		buffer = (' ' * buffer.size) if (buffer.size > 0)
		
		# Print the lines
		string.each_line.with_index do |str, index|
			str = str.strip
			str = (buffer + ": " + str) if (index > 0)
			chat_scroll(screen, array, str, color)
		end
	end
	
	# Same as chat_puts, but for use by the CLI instead of messages
	def cli_puts(screen, array, string, color=nil)
		string = clense(string)		# Remove unicode
		string.each_line do |str|
			str = str.strip
			chat_scroll(screen, array, str, color)
		end
	end

	def run(config_obj)
		RuTui::ScreenManager.loop({ :autodraw => false }) do |key|
			break if key == :ctrl_c
			@cli_field.set_focus
			if key == :enter then
				cmd_args = @cli_field.get_text.split(" ")
				cmd_name = cmd_args.shift							# Move the command name into its own variable
				unless cmd_name.nil?								# Ignore everything if the input is nil
					@HBuff.append(@cli_field.get_text)
					cmd_name = cmd_name.downcase
					case cmd_name
						when "help"
							cli_puts(@kbcli, @screen, HELP_MESSAGE, 10)
						when "go"
							cmd_args = cmd_args.join(" ")
							parent_server_id = nil
							if (!cmd_args.empty?)
								if (Parser.get_server(@open_server_id)) then parent_server_id = @open_server_id
								elsif (Parser.get_channel(@open_channel_id)) then parent_server_id = Parser.get_channel(@open_channel_id).server.id
								else parent_server_id = nil end

								channel = Parser.get_channel(cmd_args, parent_server_id)
								if (channel != nil)
									@open_server_id = channel.server.id
									@open_channel_id = channel.id
								elsif (Parser.get_server(cmd_args))
									@open_server_id = Parser.get_server(cmd_args).id
									@open_channel_id = nil
								else
									cli_puts(@kbcli, @screen, "Server/Channel not found", 1)
								end

								if (config_obj.is_a?(Setting))
									config_obj.save("channel", @open_channel_id)	# Save the current channel across runs
									config_obj.save("server", @open_server_id)		# Save the current server across runs
								end

								@text_head.set_text(tui_get_location())
							end
						when "exit"
							$bot.stop()							# Stop the bot
							exit()								# Exit
						when "status"
							stat = cmd_args.delete_at(1)		# Delete the command
							if stat == "online"
								$bot.online
								cli_puts(@kbcli, @screen, "KhajiitBot now online", 5)
							elsif stat == "idle"
								$bot.idle
								cli_puts(@kbcli, @screen, "KhajiitBot now idle", 5)
							elsif stat == "invisible"
								$bot.invisible
								cli_puts(@kbcli, @screen, "KhajiitBot now invisible", 5)
							else cli_puts(@kbcli, @screen, "Invalid status", 1)
							end
						when "play"
							msg = cmd_args.join(" ")				# Get desired string
							$bot.game=(msg)							# Set game status
							if (config_obj.is_a?(Setting))
								config_obj.save("game", msg)		# Save the current game across runs
								config_obj.save("watching", nil)
							end
						when "watch"
							msg = cmd_args.join(" ")				# Get desired string
							$bot.watching=(msg)						# Set watching status
							if (config_obj.is_a?(Setting))
								config_obj.save("watching", msg)	# Save the current vid name across runs
								config_obj.save("game", nil)
							end
						when "say"								
							msg = cmd_args.join(" ")						# Joint the rest of the input, as it is our message
							if (Parser.get_channel(@open_channel_id))
								$bot.send_message(@open_channel_id, msg)	# Send the message
							else
								cli_puts(@kbcli, @screen, "Invalid Server/Channel", 1)
							end
						when "embed"
							msg = cmd_args.join(" ")						# Joint the rest of the input, as it is our message
							$bot.send_message(@open_channel_id, nil, false,
								{"description" => msg, "color" => EMBED_MSG_COLOR})
						when "rm"
							if (@open_channel_id == nil)
								cli_puts(@kbcli, @screen, "No open channel", 1)
							else
								msg = Parser.get_channel(@open_channel_id).history(10).collect { _1.author.id }	# Make id table
								@i = 0
								@i += 1 until (msg[@i] == CLIENT_ID.to_i || @i == 11)	# Scan for Bot's ID
								Parser.get_channel(@open_channel_id).history(10)[@i].delete unless (@i == 11) 	# Delete message if its ours
							end
						when "leave"
							id = cmd_args.delete_at(1).to_i			# Delete the server ID into id
							$bot.servers.each_value {				# Scan the list of servers to find a match, then leave that server
								if _1.id == id
									cli_puts(@kbcli, @screen, "Left #{_1.name}", 5)
									_1.leave
									break 2
								end
							}
						when "dm"
							uid = cmd_args.delete_at(0)				# get the recipient uid
							msg = cmd_args.join(" ")				# Joint the rest of the input, as it is our message
							$bot.user(uid.to_i).pm(msg)
						when "uid"
							uname = Parser.get_user(cmd_args.join(" "))
							cli_puts(@kbcli, @screen, (uname)? uname.id.to_s : "Invalid User", 1)
						when "sid"
							sname = Parser.get_server(cmd_args.join(" "))
							cli_puts(@kbcli, @screen, (sname)? sname.id.to_s : "Invalid Server", 1)
						when "cid"
							cname = Parser.get_channel(cmd_args.join(" "))
							cli_puts(@kbcli, @screen, (cname)? cname.id.to_s : "Invalid Channel", 1)
						when "servers"
							$bot.servers.each_value {cli_puts(@kbcli, @screen, "#{(_1).name} : #{_1.id}", 11)}
						when "channels"
							if (@open_server_id == nil)
								cli_puts(@kbcli, @screen, "No open server", 1)
							else
								if (cmd_args.empty?)
									srv = Parser.get_server(@open_server_id) 			# If no servername argument is passed, use the current channel's parent server
								else
									srv = Parser.get_server(cmd_args.delete_at(0))		# If it is, then get the matching server object
								end
								if (srv.nil?)
									then cli_puts(@kbcli, @screen, "Invalid Server", 1)
								else
									srv.channels.each {cli_puts(@kbcli, @screen, "#{(_1).name} : #{_1.id}", 11)}
								end
							end
						when "update"
							tui_redraw()
						when "eval"
							cmd_args = cmd_args.join(" ")										# Flatten the array into a string
							cli_puts(@kbcli, @screen, "#{cmd_args}", 13)
							cmd_args.gsub!("puts", "cli_puts @kbcli, @screen, ")				# Replace puts with the custom one so the output is written to the chat TUI element
							cmd_args.gsub!("puts(", "cli_puts(@kbcli, @screen, ")
							begin
								cli_puts(@kbcli, @screen, "==> #{eval(cmd_args).to_s}")			# Run the string as ruby code and display the return value
							rescue StandardError => err
								cli_puts(@kbcli, @screen, "ERROR: #{err.message}", 1)			# If the code generates an exception, display that too
							end
						else
							cli_puts(@kbcli, @screen, "Invalid Command", 1)
					end
				end
				@cli_field.set_text("")
			elsif (key == :up)		# Handle moving up in the command history
				@HBuff.up()
				@cli_field.set_text(@HBuff.peek)
			elsif (key == :down)	# Handle moving down in the command history
				@HBuff.down()
				@cli_field.set_text(@HBuff.peek)
			else					# Handle normal keypress
				# Write char to input field
				@cli_field.write(key)
				# Update history object as we type
				@HBuff.line_buffer = @cli_field.get_text
			end
			RuTui::ScreenManager.draw
		end

		print RuTui::Ansi.clear_color + RuTui::Ansi.clear	# Were shutting down now, clear the screen
		print "\033[?25h"									# Make sure the cursor is visible
	end

	protected :clense
	protected :new_textarray
	protected :init_chat
	protected :chat_scroll
	protected :tui_get_location
	protected :tui_redraw
	protected :chat_scroll
	protected :init_chat
	protected :new_textarray

	public :chat_puts
	public :cli_puts
	public :tui_redraw
end
