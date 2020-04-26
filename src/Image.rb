
#==================================================
#     KhajiitBot  --  NotArtyom  --  03/06/18
#==================================================
#                Image Manipulation
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

$bot.command :contrast do |event, *level|
	level = level.join("").to_f
	image = ImageMod.load_tmp(event)
	if (level >= 0) then
		image.level("#{(level/4).to_s}%")
	else
		level = 0 - level
		image.level("#{(level/4).to_s}%!")
	end
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :sharpen do |event, *level|
	level = level.join("").to_f
	image = ImageMod.load_tmp(event)
	image.sharpen("0x#{(level/20).to_s}")
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :hue do |event, *degrees|
	image = ImageMod.load_tmp(event)
	image.modulate("100, 100, #{( degrees.join("").to_f * 100/180 ) + 100}")
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :saturation do |event, *level|
	image = ImageMod.load_tmp(event)
	image.modulate("100, #{level.join("")}, 300")
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :bright do |event, *level|
	image = ImageMod.load_tmp(event)
	image.modulate(level.join(""))
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :rotate do |event, *degrees|
	image = ImageMod.load_tmp(event)
	image.rotate(degrees.join(""))
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :bw do |event|
	image = ImageMod.load_tmp(event)
	image.colorspace("Gray")
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :i do |event|
	image = ImageMod.load_tmp(event)
	image.combine_options do |x|
		x.channel("RGB")
		x.negate
	end
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :fuzz do |event, *level|
	image = ImageMod.load_tmp(event)
	image = image.spread(level.join(""))
	ImageMod.return_img(event, image)
	return nil
end

#==================================================
