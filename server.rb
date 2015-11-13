require 'sinatra'
require "sinatra/reloader" if development?

get '/' do
  erb :geoloc
end

get '/*.js' do
  send_file "#{params[:splat].first}.js"
end

get '/foo' do
  "bar"
end
