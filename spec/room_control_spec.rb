require_relative "spec_helper"
require_relative "../room_control.rb"

def app
  RoomControl
end

describe RoomControl do
  it "responds with a welcome message" do
    get '/'

    last_response.body.must_include 'Welcome to the Sinatra Template!'
  end
end
