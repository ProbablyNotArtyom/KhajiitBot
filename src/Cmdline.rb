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
# Internal command prompt
#====================================================================================================

HEAD_HEIGHT		= 1
PROMPT_HEIGHT	= 3
CHAT_OFFSET		= HEAD_HEIGHT + PROMPT_HEIGHT

def clense(str)							# Cleans any unicode characters longer than 1 byte
	if (str.ascii_only?) then return str end
	newstr = ""
	str.each_char.with_index do |char, index|
		if /[\x00-\x7F]/ =~ char
			newstr[index] = str[index]
		else
			newstr[index] = '?'
		end
	end
	return newstr
end

def new_textarray(array, diff, size)
	if diff < 0 then
		(0..(diff.abs-1)).each do |x|
			$kbcli.delete(array[x])
		end
		array.shift(diff.abs)
		array.each do |line|
			line.move(0, diff)
		end
	else
		(0..(diff-1)).each do |x|
			array.insert(x, RuTui::Text.new({ :x => 0, :y => HEAD_HEIGHT+x, :text => " ", :foreground => 15 }))
			array[x].max_width = size[1]
			array[x].pixel = $pixel_chat
		end
		((diff)..(array.length-1)).each do |x|
			array[x].move(0, diff)
		end
	end
	array.each do |line|
		line.create
	end
	return array
end

def init_chat(screen)
	array = Array.new(RuTui::Screen.size[0]-CHAT_OFFSET) {
		RuTui::Text.new({ :x => 0, :y => HEAD_HEIGHT, :text => " ", :foreground => 15 })
	}
	array.each_with_index do |index, x|
		index.set_position(0, HEAD_HEIGHT+x)
		index.max_width = RuTui::Screen.size[1]
		index.pixel = $pixel_chat
		screen.add(index)
	end
	return array
end

def chat_scroll(screen, array, string, color=nil)
	if color == nil then color = 15 end
	numLines = (string.size / RuTui::Screen.size[1])

	numLines.downto(0) do |x|
		screen.delete(array[x])
		array.push(RuTui::Text.new({ :x => 0, :y => RuTui::Screen.size[0]-PROMPT_HEIGHT-1-x, :text => string[0..RuTui::Screen.size[1]], :foreground => color }))
		string = string[RuTui::Screen.size[1]-1..-1]
		array.last.max_width = RuTui::Screen.size[1]
		array.last.pixel = $pixel_chat
		array.last.create
		screen.add(array.last)
	end
	array.shift(numLines+1)
	(0..(array.length-numLines-2)).each do |index|
		array[index].move(0, -(numLines+1))
	end
	RuTui::ScreenManager.draw
end

def chat_puts(screen, array, string, color=nil)
	buffer = string[/^.+?(?=:)/]
	if (buffer == nil) then buffer = "" end
	if (buffer.size > 0)
		buffer = (' ' * buffer.size)
	end
	string.each_line.with_index { |str, index|
		str = str.strip
		if (index > 0)
			str = buffer + ": " + str
		end
		chat_scroll(screen, array, str, color)
	}
end

def cli_puts(screen, array, string, color=nil)
	string = clense(string)
	string.each_line { |str|
		str = str.strip
		chat_scroll(screen, array, str, color)
	}
end

def tui_redraw()
	new_size = RuTui::Screen.size
	$line_head.length = new_size[1]
	$box_chat.width = new_size[1]
	$box_chat.height = new_size[0]-CHAT_OFFSET
	$text_head.max_width = new_size[1]
	$cli_field.width = new_size[1]-2
	$cli_field.move(0, new_size[0] - $size[0])
	$box_cli.width = new_size[1]
	$box_cli.move(0, new_size[0] - $size[0])
	$fat_text_array = new_textarray($fat_text_array, new_size[0] - $size[0], $size)

	$line_head.create
	$box_chat.create
	$box_cli.create

	RuTui::ScreenManager.refit
	RuTui::ScreenManager.draw
	$size = new_size
end

def tui_get_location()
	return "Current channel: #{server_get_name($cmdServer)}/#{channel_get_name($cmdChannel)}"
end

$pixel_chat = RuTui::Pixel.new(15, 0, " ")
$pixel_head = RuTui::Pixel.new(15, 4, " ")
$pixel_cli = RuTui::Pixel.new(15, 4, " ")

$kbcli = RuTui::Screen.new
$kbcli.set_default($pixel_chat)

$box_chat = RuTui::Box.new({ :x => 0, :y => HEAD_HEIGHT, :width => RuTui::Screen.size[1], :height => RuTui::Screen.size[0]-CHAT_OFFSET })
$box_chat.corner = $pixel_chat
$box_chat.vertical = $pixel_chat
$box_chat.horizontal = $pixel_chat
$box_chat.fill = $pixel_chat
$box_chat.create
$kbcli.add($box_chat)

$box_cli = RuTui::Box.new({ :x => 0, :y => RuTui::Screen.size[0]-PROMPT_HEIGHT, :width => RuTui::Screen.size[1], :height => PROMPT_HEIGHT })
$box_cli.corner = $pixel_cli
$box_cli.vertical = $pixel_cli
$box_cli.horizontal = $pixel_cli
$box_cli.fill = $pixel_cli
$box_cli.create
$kbcli.add($box_cli)

$line_head = RuTui::Line.new({ :x => 0, :y => 0, :length => RuTui::Screen.size[1], :direction => :horizontal })
$line_head.pixel = $pixel_head
$line_head.endpixel = $pixel_head
$line_head.create
$kbcli.add($line_head)
$text_head = RuTui::Text.new({ :x => 0, :y => 0, :text => tui_get_location(), :foreground => 15 })
$text_head.pixel = $pixel_head
$kbcli.add($text_head)

$cli_field = RuTui::Textfield.new({ :x => 1, :y => RuTui::Screen.size[0]-PROMPT_HEIGHT+1, :pixel => $pixel_cli, :focus_pixel => $pixel_cli })
$cli_field.set_focus
$cli_field.width = RuTui::Screen.size[1]-2
# For some reason this isn't set to any default...
$cli_field.allow = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a + [" ", ":", "<", ">", "|", "#",
	"@", "*", ",", "!", "?", ".", "-", "_", "=", "+", "[", "]", "(", ")", "{", "}", ";", "\'", "\"", "\\", "/", "`", "~", "\$"]
$kbcli.add($cli_field)

$fat_text_array = init_chat($kbcli)

$bot.message() do |event|	# Print out any messages from the current channel
	if event.message.channel == $cmdChannel.id then
		chat_puts($kbcli, $fat_text_array, "#{event.message.author.display_name} : #{event.message.content}")
	end
end

$size = RuTui::Screen.size

Signal.trap("SIGWINCH") do
	tui_redraw()
end

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

RuTui::ScreenManager.add(:default, $kbcli)
RuTui::ScreenManager.loop({ :autodraw => false }) do |key|
	break if key == :ctrl_c
	$cli_field.set_focus
	if key == :enter then
		cmd_args = $cli_field.get_text.split(" ")
		cmd_name = cmd_args.shift.downcase					# Move the command name into its own variable
		unless cmd_name == nil								# Ignore everything if the input is nil
			case cmd_name
				when "help"					# HELP command
					cli_puts($kbcli, $fat_text_array, HELP_MESSAGE)
				when "go"					# GO command
					cmd_args = cmd_args.join(" ")
					if (!cmd_args.empty?)
						if ($cmdServer.is_a?(Discordrb::Server)) then parent_server = $cmdServer
						elsif ($cmdChannel.is_a?(Discordrb::Channel)) then parent_server = $cmdChannel.server
						else parent_server = nil end
						if (cmd_args.length == 18)
							cmd_args = cmd_args.to_i
							if ($bot.channel(cmd_args))
								$cmdChannel = $bot.channel(cmd_args)
								$cmdServer = $cmdChannel.server
							elsif (Parser.get_server(cmd_args))
								$cmdServer = Parser.get_server(cmd_args)
								$cmdChannel = nil
							end
						else
							channel = Parser.get_channel(cmd_args, parent_server)
							if (channel != nil)
								$cmdServer = channel.server
								$cmdChannel = channel
							elsif (Parser.get_server(cmd_args))
								$cmdServer = Parser.get_server(cmd_args)
								$cmdChannel = nil
							else
								cli_puts($kbcli, $fat_text_array, "Invalid Channel", 1)
							end
						end
						Config.save("channel", ($cmdChannel)? channel_get_name($cmdChannel) : nil)	# Save the current channel across runs
						Config.save("server", ($cmdServer)? server_get_name($cmdServer) : nil)		# Save the current server across runs
						$text_head.set_text(tui_get_location())
					end
				when "exit"							# EXIT command
					$bot.stop()							# Stop the bot
					exit()								# Exit
				when "status"						# STATUS command
					stat = cmd_args.delete_at(1)		# Delete the command
					if stat == "online"
						$bot.online
						cli_puts($kbcli, $fat_text_array, "KhajiitBot now online")
					elsif stat == "idle"
						$bot.idle
						cli_puts($kbcli, $fat_text_array, "KhajiitBot now idle")
					elsif stat == "invisible"
						$bot.invisible
						cli_puts($kbcli, $fat_text_array, "KhajiitBot now invisible")
					else cli_puts($kbcli, $fat_text_array, "Invalid status", 1)
					end
				when "play"								# PLAY command
					msg = cmd_args.join(" ")				# Get desired string
					$bot.game=(msg)							# Set game status
					Config.save("game", msg)				# Save the current game across runs
					Config.save("watching", nil)
				when "watch"							# WATCH command
					msg = cmd_args.join(" ")				# Get desired string
					$bot.watching=(msg)						# Set watching status
					Config.save("watching", msg)			# Save the current vid name across runs
					Config.save("game", nil)
				when "say"								# SAY command
					msg = cmd_args.join(" ")				# Joint the rest of the input, as it is our message
		            $bot.send_message($cmdChannel.id, msg)		# Send the message
				when "embed"							# EMBED command
					msg = cmd_args.join(" ")				# Joint the rest of the input, as it is our message
					$bot.send_message($cmdChannel.id, nil, false,
						{"description" => msg, "color" => EMBED_MSG_COLOR})
				when "rm"								# RM command
					msg = $cmdChannel.history(10).collect { _1.author.id }	# Make id table
					$i = 0
					$i += 1 until (msg[$i] == CLIENT_ID.to_i || $i == 11)	# Scan for Bot's ID
					$cmdChannel.history(10)[$i].delete unless ($i == 11) 	# Delete message if its ours
				when "leave"							# LEAVE command
					id = cmd_args.delete_at(1).to_i			# Delete the server ID into id
					$bot.servers.each_value {				# Scan the list of servers to find a match, then leave that server
						if _1.id == id
							cli_puts($kbcli, $fat_text_array, "Left #{_1.name}")
							_1.leave
							break 2
						end
					}
				when "dm"								# DM command
					uid = cmd_args.delete_at(0)				# get the recipient uid
					msg = cmd_args.join(" ")				# Joint the rest of the input, as it is our message
					$bot.user(uid.to_i).pm(msg)
				when "uid"								# UID command
					uname = Parser.get_user(cmd_args.join(" "))
					cli_puts($kbcli, $fat_text_array, (uname)? uname.id.to_s : "Invalid User", 1)
				when "sid"								# SID command
					sname = Parser.get_server(cmd_args.join(" "))
					cli_puts($kbcli, $fat_text_array, (sname)? sname.id.to_s : "Invalid Server", 1)
				when "cid"								# CID command
					cname = Parser.get_channel(cmd_args.join(" "))
					cli_puts($kbcli, $fat_text_array, (cname)? cname.id.to_s : "Invalid Channel", 1)
				when "servers"							# SERVERS command
					$bot.servers.each_value {cli_puts($kbcli, $fat_text_array, "#{server_get_name(_1)} : #{_1.id}")}
				when "channels"							# CHANNELS command
					srv = $cmdServer if (cmd_args.empty? && $cmdServer.is_a?(Discordrb::Server))	# If no servername argument is passed, use the current channel's parent server
					srv = Parser.get_server(cmd_args.delete_at(0)) unless (cmd_args.empty?)			# If it is, then get the matching server object
					if srv != nil
						srv.channels.each {cli_puts($kbcli, $fat_text_array, "#{channel_get_name(_1)} : #{_1.id}")}
					else
						cli_puts($kbcli, $fat_text_array, "Invalid Server", 1)
					end
				when "update"							# UPDATE command
					tui_redraw()
				when "eval"								# EVAL command
					cmd_args = cmd_args.join("")												# Flatten the array into a string
					cmd_args.gsub!("puts(", "cli_puts($kbcli, $fat_text_array, ")				# Replace puts with the custom one so the output is written to the chat TUI element
					begin
						cli_puts($kbcli, $fat_text_array, "returned: #{eval(cmd_args).to_s}")	# Run the string as ruby code and display the return value
					rescue StandardError => err
						cli_puts($kbcli, $fat_text_array, "ERROR: #{err.message}", 1)			# If the code generates an exception, display that too
					end
				else
					cli_puts($kbcli, $fat_text_array, "Invalid Command", 1)
			end
		end
		$cli_field.set_text("")
		RuTui::ScreenManager.draw
	else
		$cli_field.write(key)
		RuTui::ScreenManager.draw
	end
end
RuTui::Screen.hide_cursor
print RuTui::Ansi.clear_color + RuTui::Ansi.clear
