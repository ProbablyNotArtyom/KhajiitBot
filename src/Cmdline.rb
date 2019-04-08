
#==================================================
#     KhajiitBot  --  NotArtyom  --  07/24/18
#==================================================
#             Internal command prompt
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

HEAD_HEIGHT		= 1
PROMPT_HEIGHT	= 3
CHAT_OFFSET		= HEAD_HEIGHT + PROMPT_HEIGHT

def new_textarray(array, size_x)
	new_array = Array.new(size_x)
	new_array.replace(array)
	if size_x < array.length then
		new_array.shift(array.length - size_x)
	else
		(array.length..size_x).each do |x|
			new_array.push(RuTui::Text.new({ :x => 0, :y => HEAD_HEIGHT, :text => " ", :foreground => 15 }))
			new_array[x].max_width = RuTui::Screen.size[1]
			new_array[x].pixel = $pixel_chat
		end
	end
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

def chat_scroll(screen, array, string)
	screen.delete(array[0])
	array.shift
	array.each do |index|
		if index != nil then index.move(0,-1) end
	end
	array.push(RuTui::Text.new({ :x => 0, :y => RuTui::Screen.size[0]-PROMPT_HEIGHT-1, :text => string, :foreground => 15 }))
	array.last.max_width = RuTui::Screen.size[1]
	array.last.pixel = $pixel_chat
	screen.add(array.last)
	RuTui::ScreenManager.draw
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
$text_head = RuTui::Text.new({ :x => 0, :y => 0, :text => "Current channel: #{$bot.channel($cmdChannel.to_i).name}", :foreground => 15 })
$text_head.pixel = $pixel_head
$kbcli.add($text_head)

$cli_field = RuTui::Textfield.new({ :x => 1, :y => RuTui::Screen.size[0]-PROMPT_HEIGHT+1, :pixel => $pixel_cli, :focus_pixel => $pixel_cli })
$cli_field.set_focus
$cli_field.width = RuTui::Screen.size[1]-2
# For some reason this isn't set to any default...
$cli_field.allow = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a + [" ", ":", "<", ">", "|", "#",
	"@", "*", ",", "!", "?", ".", "-", "_", "=", "[", "]", "(", ")", "{", "}", ";"]
$kbcli.add($cli_field)

$fat_text_array = init_chat($kbcli)

$bot.message() do |event|	# Print out any messages from the current channel
	if event.message.channel == $cmdChannel then
		chat_scroll($kbcli, $fat_text_array, "#{event.message.author.display_name} : #{event.message.content}")
	end
end

RuTui::ScreenManager.add(:default, $kbcli)
RuTui::ScreenManager.loop({ :autodraw => true }) do |key|
	break if key == :ctrl_c
	$cli_field.set_focus
	$cli_field.write(key)
	if key == :enter then
		cIn = $cli_field.get_text.split(" ")
		unless cIn[0] == nil						# Ignore everything if the input is nil
			if cIn[0].downcase == "go"						# GO command
				chan = cIn.delete_at(1)							# Get the channel from the user input
				if chan != nil && chan.length == 18				# Make sure it's the right length
					$cmdChannel = chan.to_i  					# Set the current channel
					Config.save("channel", $cmdChannel)			# Save the current channel across runs
					$text_head.set_text("Current channel: #{$bot.channel($cmdChannel.to_i).name}")
				else chat_scroll($kbcli, $fat_text_array, "Invalid Channel") end	# Notify channel fuckery
			elsif cIn[0].downcase == "exit"					# EXIT command
				$bot.stop()										# Stop the bot
				exit											# Exit
			elsif cIn[0].downcase == "status"				# STATUS command
				stat = cIn.delete_at(1)							# Delete the command
				if stat == "online"
					$bot.online									# Set status as online
					chat_scroll($kbcli, $fat_text_array, "KhajiitBot now online")
				elsif stat == "idle"
					$bot.idle									# Set status as idle
					chat_scroll($kbcli, $fat_text_array, "KhajiitBot now idle")
				elsif stat == "invisible"
					$bot.invisible								# Set status as invisible
					chat_scroll($kbcli, $fat_text_array, "KhajiitBot now invisible")
				else chat_scroll($kbcli, $fat_text_array, "Invalid status") end
			elsif cIn[0].downcase == "play"					# PLAY command
				cIn.delete_at(0)								# Remove the command
				msg = cIn.join(" ")								# Get desired string
				$bot.game=(msg)									# Set game status
				Config.save("game", msg)						# Save the current game across runs
				Config.save("watching", nil)
			elsif cIn[0].downcase == "watch"				# WATCH command
				cIn.delete_at(0)								# Remove the command
				msg = cIn.join(" ")								# Get desired string
				$bot.watching=(msg)								# Set watching status
				Config.save("watching", msg)					# Save the current vid name across runs
				Config.save("game", nil)
			elsif $cmdChannel == "KhajiitBot"					# Sanity Check
				chat_scroll($kbcli, $fat_text_array, "You must select a valid channel!")# Fault if no channel has been selected
			elsif cIn[0].downcase == "say"					# SAY command
				cIn.delete_at(0)								# Delete the command from the user input
				msg = cIn.join(" ")								# Joint the rest of the input, as it is our message
	            $bot.send_message($cmdChannel, msg)				# Send the message
			elsif cIn[0].downcase == "embed"				# EMBED command
				cIn.delete_at(0)								# Delete the command from the user input
				msg = cIn.join(" ")								# Joint the rest of the input, as it is our message
				$bot.send_message($cmdChannel, nil, false, {"description" => msg, "color" => 0xa21a5d})
			elsif cIn[0].downcase == "rm"					# RM command
				msg = $bot.channel($cmdChannel).history(10).collect { |x| x.author.id }		# Make id table
				$i = 0
				until msg[$i] == CLIENT_ID.to_i || $i == 11; $i += 1 end					# Scan for Bot's ID
				unless $i == 11; $bot.channel($cmdChannel).history(10)[$i].delete end		# Delete message if its ours
			elsif cIn[0].downcase == "leave"				# LEAVE command
				id = cIn.delete_at(1).to_i						# Delete the channel ID into id
				$bot.servers.each_value {|x| 					# Scan the list of servers to find a match, then leave that server
					if x.id == id
						chat_scroll($kbcli, $fat_text_array, "Left #{x.name}")
						x.leave
						break 2
					end
				}
			elsif cIn[0].downcase == "dm"					# DM command
				cIn.delete_at(0)								# Delete the command from the user input
				uid = cIn.delete_at(0)							# get the recipient uid
				msg = cIn.join(" ")								# Joint the rest of the input, as it is our message
				$bot.user(uid.to_i).pm(msg)
			elsif cIn[0].downcase == "uid"					# UID command
				cIn.delete_at(0)								# Remove the command
				uname = Parser.get_user(cIn.join(" "))			# Get the username
				if uname != nil
					chat_scroll($kbcli, $fat_text_array, uname.id.to_s)
				else
					chat_scroll($kbcli, $fat_text_array, "Invalid User")
				end
			elsif cIn[0].downcase == "sid"					# SID command
				cIn.delete_at(0)								# Remove the command
				sname = Parser.get_server(cIn.join(" "))			# Get the server name
				if sname != nil
					chat_scroll($kbcli, $fat_text_array, sname.id.to_s)
				else
					chat_scroll($kbcli, $fat_text_array, "Invalid Server")
				end
			elsif cIn[0].downcase == "list"					# LIST command
				servers = $bot.servers.each_value {|x| 			# For each server, print out its name and ID
					chat_scroll($kbcli, $fat_text_array, "#{x.name} : #{x.id}")
				}
			else chat_scroll($kbcli, $fat_text_array, "Invalid Command") 			# Notify invalid command input
			end
			puts("")
		end
		$cli_field.set_text("")
	end
end
RuTui::Screen.hide_cursor
print RuTui::Ansi.clear_color + RuTui::Ansi.clear
