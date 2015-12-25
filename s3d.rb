require 'yaml'
require 'sinatra'
require 'instagram'
require 'parse-ruby-client'

#Load config yaml file
configYaml = YAML.load_file("clientConfig.yaml")
parseConfig = configYaml["parse"]
instagramConfig = configYaml["instagram"]

#Parse Client setup
Parse.init(application_id: parseConfig["application_id"],
           api_key: parseConfig["api_key"])

# Instagram Client setup
enable :sessions
CALLBACK_URL = instagramConfig["callback_url"]
Instagram.configure do |config|
  config.client_id = instagramConfig["client_id"]
  config.client_secret = instagramConfig["client_secret"]
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
  tagRecentMedia = client.tag_recent_media(tags[0].name)
  tagRecentMedia.each do |media_item|
    # if already uploaded then stop the loop
    if parseConfig["last_id"] >= media_item.id
      break
    end
    
    # create the new parse.com 'Media' object
    parseObject = Parse::Object.new("Media").tap do |object|
      object["storeName"] = storeName(media_item)
      object["thumbnailUrl"] = media_item.images.thumbnail.url
      object["instaId"] = media_item.id
      object["location"] = location(media_item)
    end
    result = parseObject.save
    puts result
  end

  # write the last 'Media' object's instaId to clientConfig.yaml
  configYaml["parse"]["last_id"] = tagRecentMedia[0].id
  file = File.open("clientConfig.yaml", "w")
  file.write(YAML.dump(configYaml))
  file.close

  html = "<h1> Done. </h1>"
  html
end

get "/update_page" do
  html = "<h1> Update Page </h1>"
  html
end

get "/page_test" do
  html = "<h1> #{parseConfig["last_id"]} </h1>"
  html
end

def storeName(item)
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
