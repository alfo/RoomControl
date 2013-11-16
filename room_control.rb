require 'yaml'

class RoomControl < Sinatra::Base

  set :public_folder => "public", :static => true

  # Create the Serial Port instance
  # On Mac, the Arduino will always be tty.usbmodemXXXX
  # For my Mac Mini Server, it always seems to be 1431

  before do
    @sp = SerialPort.new "/dev/tty.usbmodem1431"
  end

  # Load the SQLite Database of presets for RGB mixes
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/database.sqlite")

  class Preset
    include DataMapper::Resource

    property :id, Serial
    property :number, Integer
    property :dmx, String
  end

  DataMapper.finalize.auto_upgrade!

  # Hashes for the two RGB fixtures
  # Each is a hash of the DMX channels needed for R, G, B, and dimmer
  FIX_1 = {:red => 1, :green => 2, :blue => 3, :dimmer => 4}
  FIX_2 = {:red => 5, :green => 6, :blue => 7, :dimmer => 8}

  # Core write def
  def write(string)
    # Writes a string to the Arduino with a newline
    @sp.write "#{string}\r\n"
  end

  # Core DMX send def 
  def send_dmx(channel, value)

    # Write the channel and value in the format for Arduino
    write("#{channel}c")
    write("#{value}w")
  end

  # To test the server works
  get "/" do
    erb :welcome
  end

  # Triggers one of the DMX presets to be put into action
  post '/trigger' do

    # Load the preset from the SQLite Database
    @preset = Preset.first(:number => params[:preset]).dmx

    # Decode it from YAML into a Ruby hash
    @dmx = YAML::load(@preset)
    
    # For each channel in the prest, write it to the DMX shield
    @dmx.each do |x, y|
      send_dmx(x, y)
    end

    # So I don't get Lint errors
    'Done'
  end

  # This is to turn on and off the relay
  post '/relay' do

    # The relay is on DMX address 500
    if params[:relay] == 'on'
      # 1 means onn
      send_dmx(500, 1)
    else
      # 0 means off
      send_dmx(500, 0)
    end

    # Avoid Lint errors
    'done'
  end

  # Delete the presets and make them again
  # Good for debugging
  get '/make_defaults' do

    # Destroy all the presets
    Preset.all.each do |p|
      p.destroy
    end

    # Define all the presets
    @preset_1 = {1 => 0, 2 => 255, 3 => 255, 4 => 183, 5 => 0, 6 => 255, 7 => 255, 8 => 183}
    @preset_2 = {1 => 255, 2 => 255, 3 => 0, 4 => 183, 5 => 255, 6 => 255, 7 => 0, 8 => 183}
    @preset_3 = {1 => 255, 2 => 0, 3 => 75, 4 => 183, 5 => 255, 6 => 0, 7 => 75, 8 => 183}
    @preset_4 = {1 => 255, 2 => 25, 3 => 0, 4 => 183, 5 => 255, 6 => 25, 7 => 0, 8 => 183}
    
    # This one turns them off (RGB all at 0)
    @preset_10 = {1 => 0, 2 => 0, 3 => 0, 4 => 183, 5 => 0, 6 => 0, 7 => 0, 8 => 183}

    # Creat all the presets!
    Preset.create!(
      :number => 1,
      :dmx => YAML::dump(@preset_1)
    )
    Preset.create!(
      :number => 2,
      :dmx => YAML::dump(@preset_2)
    )
    Preset.create!(
      :number => 3,
      :dmx => YAML::dump(@preset_3)
    )
    Preset.create!(
      :number => 4,
      :dmx => YAML::dump(@preset_4)
    )
    Preset.create!(
      :number => 10,
      :dmx => YAML::dump(@preset_10)
    )
  end
end
