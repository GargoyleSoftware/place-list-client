require 'rubygems'
require 'sinatra'

set :public, File.dirname(__FILE__) + '/public'

get '/' do
  erb :index
end