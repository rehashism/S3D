require 'yaml'
require 'json'
require 'sinatra'
require 'instagram'
require 'parse-ruby-client'

#Load config yaml file
config_yaml = YAML.load_file("client_config.yaml")
parse_config = config_yaml["parse"]
instagram_config = config_yaml["instagram"]

#Parse Client setup
Parse.init(application_id: parse_config["application_id"],
           api_key: parse_config["api_key"])

# Instagram Client setup
enable :sessions
CALLBACK_URL = instagram_config["callback_url"]
Instagram.configure do |config|
  config.client_id = instagram_config["client_id"]
  config.client_secret = instagram_config["client_secret"]
end

get "/" do
  '<a href="/oauth/connect">Connect with Instagram</a>'
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(redirect_uri: CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], redirect_uri: CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/nav"
end

get "/nav" do
  html =
    """
    <ol>
    <li><a href='/parse_and_update_data'>Parse and Update Data</a></li>
    <li><a href='/update_page'>Update Page</a></li>
    <li><a href='/page_test'>Page Test</a></li>
    </ol>
    """
  html
end

get "/parse_and_update_data" do
  client = Instagram.client(access_token: session[:access_token])
  tags = client.tag_search("현호시대")
  tag_recent_media = client.tag_recent_media(tags[0].name)
  tag_recent_media.each do |media_item|
    # if already uploaded then stop the loop
    if parse_config["last_id"] >= media_item.id
      break
    end
    
    # create the new parse.com 'Media' object
    parse_object = Parse::Object.new("Media").tap do |object|
      object["storeName"] = store_name(media_item)
      object["thumbnailUrl"] = media_item.images.thumbnail.url
      object["instaId"] = media_item.id
      object["location"] = location(media_item)
    end
    result = parse_object.save
    puts result
  end

  # write the last 'Media' object's instaId to client_config.yaml
  config_yaml["parse"]["last_id"] = tag_recent_media[0].id
  file = File.open("client_config.yaml", "w")
  file.write(YAML.dump(config_yaml))
  file.close

  html = "<h1> Done. </h1>"
  html
end

get "/update_page" do
  json_text = JSON.parse(File.read("text.json"))
  
  
  
  html = "<h1> Update Page </h1>"
  html
end

get "/page_test" do
  html = "<h1> #{parse_config["last_id"]} </h1>"
  html
end

def store_name(item)
  if item.location
    item.location.name
  else
    item.caption.text.split("#")[2]
  end
end

def location(item)
  if item.location
    Parse::GeoPoint.new({
      "latitude" => item.location.latitude,
      "longitude" => item.location.longitude
    })
  else
    Parse::GeoPoint.new({
      "latitude" => 0,
      "longitude" => 0
    })
  end
end
