require 'sinatra/base'
require './app/foliator_manager'

class FoliatorApp < Sinatra::Application
  configure { set :server, :puma }

  post '/' do
    FoliatorManager.process request.body.read
  end
end
