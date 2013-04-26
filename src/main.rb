require 'json'
require 'stringio'
$LOAD_PATH.concat Dir.glob File.expand_path '~/git/mcsakura/src/ruby/2.1.0/gems/**/lib/'
require 'sinatra/base'
import 'org.bukkit.Bukkit'
import 'org.bukkit.Material'

class LingrBot < Sinatra::Base
  get '/' do
    {RUBY_DESCRIPTION: RUBY_DESCRIPTION, bukkit_version: Bukkit.getBukkitVersion}.inspect
  end

  post '/' do
    begin
      JSON.parse(request.body.string)['events'].map {|event|
        msg = event['message']
        next unless %w[computer_science mcujm].include? msg['room']
        EventHandler.on_lingr(msg)
        case event['message']['text']
        when '/list'
          p 'list!'
          Bukkit.getOnlinePlayers.map(&:getName).inspect
        else
          ''
        end
      }.join
    rescue => e
      p e
      ''
    end
  end
end

Thread.start do
  Rack::Handler::WEBrick.run LingrBot, Port: 8126, AccessLog: [], Logger: WEBrick::Log.new("/dev/null")
end

module EventHandler
  module_function
  def on_load(plugin)
    @plugin = plugin
    p :on_load, plugin
  end

  def on_lingr(message)
    return if Bukkit.getOnlinePlayers.empty?
    later 0 do
      broadcast "#{message['nickname']}: #{message['text']}"
    end
  end

  def on_async_player_chat(evt)
    p :chat, evt.getPlayer
  end

  def on_player_login(evt)
    p :login, evt
    p evt.getPlayer
  end

  def on_block_break(evt)
    #evt.setCancelled true
    evt.getBlock.setType(Material.LAVA)
  end

  def later(tick, &block)
    Bukkit.getScheduler.scheduleSyncDelayedTask(@plugin, block, tick)
  end

  def broadcast(*msgs)
    Bukkit.getServer.broadcastMessage(msgs.join ' ')
  end
end

EventHandler
