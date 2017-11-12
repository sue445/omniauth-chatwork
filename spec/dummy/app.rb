require "sinatra"
require "webrick/https"
require "omniauth/builder"
require "dotenv"
require "pry"
require "faraday_curl"
require "pp"

require "omniauth-chatwork"

Dotenv.load

module OAuth2Ext
  def connection
    return @connection if @connection

    super

    @connection.request :curl, Logger.new(STDOUT), :debug

    @connection
  end
end

OAuth2::Client.class_eval do
  prepend OAuth2Ext
end

set :server_settings,
    SSLEnable: true,
    SSLCertName: [["CN", WEBrick::Utils.getservername]]

use Rack::Session::Cookie
use OmniAuth::Builder do
  # provider :chatwork, ENV["CLIENT_ID"], ENV["CLIENT_SECRET"]

  provider :chatwork, ENV["CLIENT_ID"], ENV["CLIENT_SECRET"], scope: ["users.all:read", "rooms.all:read_write", "contacts.all:read_write"]
end

get "/" do
  <<-HTML
    <a href="/auth/chatwork">Sign in with ChatWork</a>
  HTML
end

get "/auth/:name/callback" do
  auth = request.env["omniauth.auth"]
  pp auth
  auth.to_json
end

get "/auth/failure" do
  <<-HTML
    <dl>
      <dt>message</dt>
      <dd>#{params[:message]}</dd>

      <dt>origin</dt>
      <dd>#{params[:origin]}</dd>

      <dt>strategy</dt>
      <dd>#{params[:strategy]}</dd>
    </dl>
  HTML
end
