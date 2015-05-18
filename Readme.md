# 构建ruby版简易web server


## todo

* 最近使用
* 统计使用频率
* gem 工具化
* 支持行号
* 代码高亮
* 便捷访问控制 

#ruby -rwebrick -e'WEBrick::HTTPServer.new(:Port => 3000, :DocumentRoot => Dir.pwd).start'
#Rack::Directory
alias fileshare="python -m SimpleHTTPServer 8844"

从shareup中抽出写成功能模块


Here it is:

ruby -run -e httpd . -p 5000

(from Aaron Patterson’s tweet found via Zach Morek)

It’s pretty much the same, except it’s written in Ruby. More often than not, that’s not a big difference — except I can understand the code behind it.

#
# = un.rb
#
# Copyright (c) 2003 WATANABE Hirofumi <eban@ruby-lang.org>
#
# This program is free software.
# You can distribute/modify this program under the same terms of Ruby.

# [...]

##
# Run WEBrick HTTP server.
#
# ruby -run -e httpd -- [OPTION] DocumentRoot
#
# --bind-address=ADDR address to bind
# --port=NUM listening port number
# --max-clients=MAX max number of simultaneous clients
# --temp-dir=DIR temporary directory
# --do-not-reverse-lookup disable reverse lookup
# --request-timeout=SECOND request timeout in seconds
# --http-version=VERSION HTTP version
# -v verbose
#

def httpd
  setup("", "BindAddress=ADDR", "Port=PORT", "MaxClients=NUM", "TempDir=DIR",
        "DoNotReverseLookup", "RequestTimeout=SECOND", "HTTPVersion=VERSION") do
    |argv, options|
    require 'webrick'
    opt = options[:RequestTimeout] and options[:RequestTimeout] = opt.to_i
    [:Port, :MaxClients].each do |name|
      opt = options[name] and (options[name] = Integer(opt)) rescue nil
    end
    unless argv.size == 1
      raise ArgumentError, "DocumentRoot is mandatory"
    end
    options[:DocumentRoot] = argv.shift
    s = WEBrick::HTTPServer.new(options)
    shut = proc {s.shutdown}
    siglist = %w"TERM QUIT"
    siglist.concat(%w"HUP INT") if STDIN.tty?
    siglist &= Signal.list.keys
    siglist.each do |sig|
      Signal.trap(sig, shut)
    end
    s.start
  end
end

So how does it work? It’s actually a little surprising. Here’s the command again for reference:

ruby -run -e httpd . -p 5000

In order:

    Obviously, ruby is the normal Ruby interpreter.
    The -r switch requires a file in the load path, in this case Ruby’s lib directory. In this case, it’s loading a file called un.rb so that it looks like -run when taken as a whole. (It could be written as -r un as well.) This is similar to ubygems.rb which you may have seen as ruby -rubygems. That seems like an ugly solution, but it’s elegant in its own way. This naming hack is only really an option for files in Ruby itself, anyway.
    As you can see above, httpd is just a method, which is executed by -e.
    The DocumentRoot argument . is just taken as a standard argument using ARGV, which I found surprising.
    Finally, the port is set using the setup method, which in turn calls out to the built in OptionParser.

While that code is probably too clever, it’s nice to have a simple HTTP server wherever I have Ruby.

Even more, the concept is reusable:

# File: ake.rb
# Minimalist rake.  :)
def greet
  puts "Hello, #{ ARGV[0] }!"
end

Here’s the output

$ ruby -I . -rake -e greet Ben
Hello, Ben!
$ ruby -r ./ake -e greet Ben
Hello, Ben!

That could be a nice minimalist way to write some helper scripts without Rake or Thor.
