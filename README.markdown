Campfirc is a little script to proxy communication between Campfire and IRC.

It uses [Tinder](http://tinder.rubyforge.org/) to talk to Campfire, and [Isaac](https://github.com/ichverstehe/isaac/) to connect to IRC. Its purpose is to allow an individual (me) to use Campfire as a local IRC log, as well as a mobile client that I can use to maintain context.

To get started, just copy config.yml.example to config.yml, and update to your own credentials. It looks like this:

    campfire:
      subdomain: foo
      email: foo@example.com
      password: pass
      owner: Mister X.
    irc:
      server: irc.freenode.net
      port: 6667
      nick: foo

On the campfire side of things, you'll want to set up a private chat room for each IRC channel you want to join, named server#channel, for instance irc.freenode.net#merb. When campfirc is started, it will scan all the chat rooms in your campfire subdomain for ones matching the server specified in the config file, and then join those channels once connected to IRC.

Future TODO items:

- Authenticate IRC connection via nickserv
- poll campfire rooms, quit irc channels without a matching room, join channels where room has been created (right now, just restart the bot)
