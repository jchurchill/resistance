# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Resistance::Application.initialize!

# TESTING the websocket integration
# Depends on em-websocket gem (included in resistance/Gemfile)
Thread.new { # Start on a new thread since this thread is rails's thread
	EventMachine.run {
		@chatroom = EM::Channel.new

		EventMachine::WebSocket.start(:host => "127.0.0.1", :port => 8080) do |ws|
		  ws.onopen {
	      sid = @chatroom.subscribe { |msg| ws.send msg }
	      open_msg = { 'msg' => "(#{sid} connected!)", 'class' => 'server' }.to_json
	      @chatroom.push open_msg

	      ws.onmessage { |msg|
	      	full_msg = { 'msg' => "[ #{sid} ]: #{msg}", 'class' => 'user' }.to_json
	        @chatroom.push full_msg
	      }

	      ws.onclose {
	        @chatroom.unsubscribe(sid)
	      }
	    }
		end

		puts 'Websocket listener started'
	}
}