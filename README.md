# S3D
Sung Soo Si Dea

#Gem Install

    gem install sinatra
    gem install instagram
    gem install parse-ruby-client
#Setup config YAML file

    parse:
      application_id: YOUR_PARSE_APPLICATION_ID
      api_key: YOUR_PARSE_REST_API_KEY
    instagram:
      callback_url: yourserver.com/oauth/callback
      client_id: YOUR_INSTAGRAM_CLIENT_ID
      client_secret: YOUR_INSTAGRAM_CLIENT_SECRET
#Run Server

    ruby s3d.rb -o yourserver.com -p 8000

#Run GoogleMap Web Page with Python Simple Server

    python -m SimpleHTTPServer
