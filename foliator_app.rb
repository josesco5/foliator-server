require 'sinatra/base'

class FoliatorApp < Sinatra::Application
  configure { set :server, :puma }

  get '/' do
    'Hello World'
  end
end
