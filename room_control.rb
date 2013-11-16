require 'yaml'

class RoomControl < Sinatra::Base

  set :public_folder => "public", :static => true

  before do
    @sp = SerialPort.new "/dev/tty.usbmodem1431"
  end

  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/database.sqlite")

  class Preset
    include DataMapper::Resource

    property :id, Serial
    property :number, Integer
    property :dmx, String
  end

  DataMapper.finalize.auto_upgrade!

  FIX_1 = {:red => 1, :green => 2, :blue => 3, :dimmer => 4}
  FIX_2 = {:red => 5, :green => 6, :blue => 7, :dimmer => 8}

  def write(string)
    @sp.write "#{string}\r\n"
  end

  def send_dmx(channel, value)
    write("#{channel}c")
    write("#{value}w")
  end

  get "/" do
    erb :welcome
  end

  post '/trigger' do
    @preset = Preset.first(:number => params[:preset]).dmx
    @dmx = YAML::load(@preset)
    @dmx.each do |x, y|
      p "#{x} #{y}"
      send_dmx(x, y)
    end

    'Done'
  end

  post '/relay' do
    if params[:relay] == 'on'
      send_dmx(500, 1)
    else
      send_dmx(500, 0)
    end

    'done'
  end

  get '/make_defaults' do

    Preset.all.each do |p|
      p.destroy
    end

    p @preset_1 = {1 => 0, 2 => 255, 3 => 255, 4 => 183, 5 => 0, 6 => 255, 7 => 255, 8 => 183}
    p @preset_2 = {1 => 255, 2 => 255, 3 => 0, 4 => 183, 5 => 255, 6 => 255, 7 => 0, 8 => 183}
    p @preset_3 = {1 => 255, 2 => 0, 3 => 75, 4 => 183, 5 => 255, 6 => 0, 7 => 75, 8 => 183}
    p @preset_4 = {1 => 255, 2 => 25, 3 => 0, 4 => 183, 5 => 255, 6 => 25, 7 => 0, 8 => 183}
    p @preset_10 = {1 => 0, 2 => 0, 3 => 0, 4 => 183, 5 => 0, 6 => 0, 7 => 0, 8 => 183}

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
