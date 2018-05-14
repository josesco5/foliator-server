require 'sinatra/base'
require 'document/foliator'

class FoliatorApp < Sinatra::Application
  configure { set :server, :puma }

  get '/' do
    puts Document::Foliator::VERSION
    'Hello World'
  end
end
