# KhajiitBot

KhajiitBot is a discord bot written in ruby for use on the Khajiit_IRL discord server. It has a lot of functions that essentially clone the ones provided by furbot and the like, as well as some extras. The most interesting feature is probably the trade function, which allows users to trade images with the bot.

## Summary of content

KhajiitBot has a multitude of functions mostly comprizing of user interaction functions. Heres a quick overview:

 * **`k.yiff @[user]`**		: sends a yiffy message.
 * **`k.hug @[user]`**		: hugs another user.
 * **`k.kiss @[user]`**		:  kisses another user.
 * **`k.stab @[user]`**		: stabs another user.
 * **`k.shoot @[user]`**	: shoots another user.
 * **`k.pet @[user]`**		: pets another user.
 * **`k.bless @[user]`**	: blesses another user.
 * **`k.nuke @[user]`**		: nukes another user.
 * **`k.meow @[user]`**		: meow at another user.
 * **`k.vore @[user]`**		: vore another user.
 * **`k.grope @[user]`**	: gropes another user. Why would you want that.
 * **`k.f @[user]`**		: pays respects, optionally to another user.
 * **`k.boof @[user]`**		: rip da boof, or pass da boof to a fren.

For a full list of commands, look at the k.help files in ext/sys/help

There is a command line available to the host with a few functions:

 * **`go`**		 	 : Change to a different channel. args: [channel id]
 * **`exit`**		 : Exits KhajiitBot
 * **`status`**		 : Sets KhajiitBot's status. args: [online|idle|invisible]
 * **`play`**		 : Sets the playing status. args: [string]
 * **`watch`**		 : Sets the watching status. args: [string]
 * **`say`**		 : Sends a text message. args: [string]
 * **`embed`**		 : Sends an embed message. args: [string]
 * **`rm`**		 	 : Removes the last sent message.
 * **`leave`**		 : Leaves a channel. args: [channel id]
 * **`dm`**			 : Direct messages a user. args: [user id][message]
 * **`uid`**		 : Prints the ID of a user by name. args: [username]
 * **`sid`**		 : Prints the ID of a server by name. args: [server name]
 * **`servers`**	 : Prints a list of servers KhajiitBot is in.
 * **`channels`**	 : Prints a list of all channels from every server KhajiitBot is in.
 * **`update`**		 : Forces the command UI to be redrawn."

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
  * minimagick
  * rutui

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
* [MiniMagick](https://github.com/minimagick/minimagick) - MiniMagick ruby gem

## Contributing

Please read [CONTRIBUTING.md](https://github.com/ProbablyNotArtyom/KhajiitBot/blob/master/CONTRIBUTING.md) for info about contributing to KhajiitBot, aswell as when contributions are wanted.

## Authors

* **Carson Herrington / NotArtyom** - *All Code* - [Website](http://notartyoms-box.net)
* **Members of the Khajiit_IRL discord** - *Funny Strings* - [Khajiit_IRL](https://www.reddit.com/r/KHAJIIT_IRL/)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Thanks to the people behind DiscordRB for making their wonderful API implementation for ruby
* Thanks the the Khajiit_IRL discord for helping with suggestions and strings
