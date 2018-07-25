# KhajiitBot

KhajiitBot is a discord bot written in ruby for use on the Khajiit_IRL discord server. It has a lot of functions that essentially clone the ones provided by furbot and the like, as well as some extras. The most interesting feature is probably the trade function, which allows users to trade images with the bot. 

## Summary of content

KhajiitBot has a multitude of functions mostly comprizing of user interaction functions. Heres a quick overview:

  * k.random <max value>  :  generates a truly random number with max value. default max is 10.
  * k.8ball [question]    :  answeres any question with true randomness.
  * k.rate @[user]        :  rates another user on a scale from 0 to 10. slightly less random...
  * k.katia               :  returns a random katia image.
  * k.hug @[user]     :  hugs another user.
  * k.kiss @[user]    :  kisses another user.
  * k.stab @[user]    :  stabbes another user.
  * k.shoot @[user]   :  shoots another user.
  * k.pet @[user]     :  pets another user.
  * k.bless @[user]   :  blesses another user.

There are also functions based on image sharing:

  * k.trade [image]       :  adds user image to meme pool and sends a random meme back.
  * k.image               :  gets a random image from the k.trade pool.
  * k.lewd <image>        :  adds user image to lewd pool and sends a random lewd back.

The Trade function is the most interesting. The bot has a pool of images saved in a folder in the project directory. 
When a user uses the Trade command, they supply an image to trade with the Bot.
The bot will then take that image and add it to its own pool, while also returning a random image from the pool back to the user.
The Image function just returns a random image without modifying the pool.

The Lewd function is essentially the same thing but with lewd instead of memes.

There is a command line available to the host with a few functions:

  * say <channel id> "message"   : Sends a message to a channel.
  * embed <channel id> "message" : Sends an embedded message to a channel.
  * exit                         : Stops the bot.

There are many admin commands available to the owner:

  * nsfwadd #channel                                :  Adds a channel to the nsfw whitelist.
  * nsfwpurge #channel                              :  Removes a channel from the nsfw whitelist.
  * blacklist [list, add, remove] @user <command>   :  Interacts with the user blacklist.
  * usermod @user [0, 1, 2]                         :  Sets a user's permission level. 0 is blocked, 1 is normal usage, 2 is admin.
  * servermod                                       :  Sets an entire server to a permit level.
  * listmod                                         :  Lists the permissions of everyone.

Users with permission level 2 are the only ones able to use admin commands.

## Usage

You will need ruby installed on the host machine in order to run the bot. Here is a list of thee required Gems:

  * discordrb
  * openssl

Once all required gems are installed, simply run KhajiitBot.rb using ruby

```
ruby <path to project>/src/KhajiitBot.rb
```

This code has been tested on Linux using ruby 2.3.3 using kernel 4.9.0
It has not yet been tested on Windows systems (If anyone gets runs it sucessfuly, let me know!).

## Deployment

To move the bot onto another system, such as a server, just copy the entire project root onto the new machine. Make sure that the entire contents of the project is owned by whatever user you intend to run the bot with. Make sure to also install ruby and all of the required Gems.

## Links

* [DiscordRB](https://rubygems.org/gems/discordrb) - Discord API interface for ruby
* [openSSL](https://rubygems.org/gems/openssl) - OpenSSL GEM for ruby
* [ruby](https://www.ruby-lang.org/en/downloads/) - Ruby runtime environment 

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for info about contributing to KhajiitBot, aswell as when contributions are wanted.

## Authors

* **Carson Herrington / NotArtyom** - *All Code* - [Website](http://notartyoms-box.com)
* **Members of the Khajiit_IRL discord** - *Funny Strings* - [Khajiit_IRL](https://www.reddit.com/r/KHAJIIT_IRL/)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Thanks to the people behind DiscordRB for making their wonderful API implementation for ruby
* Thanks the the Khajiit_IRL discord for helping with suggestions and strings

