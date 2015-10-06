require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "This tweet is #{message.length - 140} characters too long. Please shorten the tweet in order to post"
    end
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    screen_names = @client.followers.collect {|follower| @client.user(follower).screen_name.downcase }
    p screen_names
    if screen_names.include?(target)
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "You can only DM people who follow you"
    end
  end

  def followers_list
    screen_names = []
    @client.followers.each do |follower|
      screen_names << @client.user(follower).screen_name.downcase
    end
    screen_names
  end

  def spam_my_followers(message)
    followers_list.each do |follower|
      dm(follower, message)
    end
  end

  def everyones_last_tweet
    friends = @client.friends
    friends.each {|f| puts f}
    friends = (friends.each {|f| @client.user(f).screen_name.downcase}).sort
    friends.each do |friend|
      timestamp = @client.user(friend).status.created_at
      puts "#{@client.user(friend).screen_name} said this on #{timestamp.strftime("%A, %b, %d")}:"
      puts "#{@client.user(friend).status.text}"
    end
  end

  def shorten(original_url)
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    puts "Shortening this URL: #{original_url}"
    bitly.shorten(original_url).short_url
  end

  def run
    puts "Welcome to the JSL Twitter Client"
    command = ""
    while command != "q"
      printf "Enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
      when 'q'
        puts "Goodbye"
      when 't'
        tweet(parts[1..-1].join(" "))
      when 'dm'
        dm(parts[1], parts[2..-1].join(" "))
      when 'spam'
        spam_my_followers(parts[1..-1].join(" "))
      when 'elt'
        everyones_last_tweet
      when 's'
        shorten(parts[1..-1].join(" "))
      when 'turl'
        tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
      else
        puts "Sorry, I don't know how to #{command}"
      end
    end
  end
end

blogger = MicroBlogger.new
blogger.run


