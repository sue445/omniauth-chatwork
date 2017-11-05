require "sinatra"
require "webrick/https"

set :server_settings,
    SSLEnable: true,
    SSLCertName: [["CN", WEBrick::Utils.getservername]]

get "/" do
  "https page"
end
