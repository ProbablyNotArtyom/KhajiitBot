
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
	if level >= 100 then
		level = level - 100
		image = image.sigmoidal_contrast_channel((level/2), Magick::QuantumRange.to_f * 0.50, true, Magick::AllChannels)
	else
		level = 100 - level
		image = image.sigmoidal_contrast_channel((level/2), Magick::QuantumRange.to_f * 0.50, false, Magick::AllChannels)
	end
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :saturation do |event, *level|
	level = level.join("").to_f
	image = ImageMod.load_tmp(event)
	image = image.modulate(1, (level/100)*2, 1)
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :sharpen do |event, *level|
	level = level.join("").to_f
	image = ImageMod.load_tmp(event)
	image = image.sharpen(4, level/20)
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :hue do |event, *level|
	level = level.join("").to_f
	image = ImageMod.load_tmp(event)
	image = image.quantize(256, Magick::GRAYColorspace)
	image = image.colorize(0.60, 0.60, 0.60, Magick::Pixel.from_hsla(level, 100.0, 100.0, 1.0))
	image = image.sigmoidal_contrast_channel(15.0, Magick::QuantumRange.to_f * 0.50, true, Magick::AllChannels)
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :bright do |event, *level|
	level = level.join("").to_f
	image = ImageMod.load_tmp(event)
	if level >= 100 then
		level = level.to_f - 100.0
		image = image.level(0.0 - (Magick::QuantumRange.to_f*((level/25.0))), Magick::QuantumRange, 1.0)
	else
		level = 100.0 - level.to_f
		image = image.level(0.0, Magick::QuantumRange.to_f * (1.0+(level/16)), 1.0)
	end
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :rotate do |event, *level|
	level = level.join("").to_f
	image = ImageMod.load_tmp(event)
	image = image.rotate(degrees)
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :bw do |event|
	image = ImageMod.load_tmp(event)
	image = image.quantize(256, Magick::GRAYColorspace)
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :i do |event|
	image = ImageMod.load_tmp(event)
	image = image.negate(false)
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :fuzz do |event, *level|
	level = level.join("").to_f
	image = ImageMod.load_tmp(event)
	image = image.spread(level)
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :dither do |event, *level|
	level = level.join("").to_i
	image = ImageMod.load_tmp(event)
	image = image.ordered_dither("h3x4a")
	ImageMod.return_img(event, image)
	return nil
end

$bot.command :noise do |event|
	image = ImageMod.load_tmp(event)
	tmpImg = Magick::Image.new(image.columns, image.rows)
	tmpImg.color_reset!("black")
	tmpImg = tmpImg.add_noise(Magick::ImpulseNoise)
	tmpImg = tmpImg.transparent("black", Magick::TransparentOpacity)
	tmpImg = tmpImg.modulate(1, 0.5, 1)
	tmpImg = tmpImg.blur_image(0.0, 1.0)

	image.composite!(tmpImg, Magick::CenterGravity, Magick::OverCompositeOp)
	ImageMod.return_img(event, image)
	return nil
end

#==================================================
