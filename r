require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require 'exifr/jpeg'
require 'mini_exiftool'

require 'cloudinary'
require 'cloudinary/uploader'
require 'cloudinary/utils'

Cloudinary.config do |config|
  config.cloud_name = "dhieluttu"
  config.api_key    = "567638663797367"
  config.api_secret = "idUbLB5JT23UeTHCE5GQDD2wu-c"
  config.secure     = true
end


enable :sessions

before do
  @current_user = User.find(session[:user]) if session[:user]
end

get '/' do
  erb :index
end


get '/newmap' do
  @groups = Group.all
  erb :newmap
end

get '/maps/:id' do
  @group = Group.find(params[:id])
  unless @group.is_share || @group.users.include?(@current_user)
    halt 403, "このグループの閲覧権限がありません"
  end
  erb :map
end

get '/profile' do
    erb :profile 
end

get '/newpicture' do
    erb :newpicture
end

get '/newgroup' do
    erb :newgroup
end

post '/newgroup' do
  group = Group.new(name: params[:group_name], is_share: params[:is_share])
  if group.save
    GroupUser.create!(group: group, user: @current_user)
    (params[:user_ids] || []).each do |uid|
      user = User.find_by(id: uid)
      GroupUser.create!(group: group, user: user) if user
    end
    session[:response] = {code: 200, messages: "成功しました"}
  else
    session[:response] = {code: 400, messages: place.errors.full_messages}
  end
  redirect '/'
end
  

# post "/newpicture" do
#   tempfile = params[:photo][:tempfile]
#   jpeg = EXIFR::JPEG.new(tempfile.path)
  
#   puts "----------------------------"
#   # puts "#{jpeg}----"
  
#   # # GPS情報を取得する
#   if jpeg.gps
#     puts "GPS Latitude: #{jpeg.gps.latitude}"
#     puts "GPS Longitude: #{jpeg.gps.longitude}"
#   else
#     puts "GPS情報が見つかりませんでした。"
#   end
  
#   puts "#{params[:photo]}"
  
#   place = Place.new(place_name: params[:place_name], category_id: params[:category_id], photo: params[:photo], lat: jpeg.gps.latitude, lng: jpeg.gps.longitude, user_id: User.find(session[:user]).id, group_id: params[:group_id])
#   puts @current_user.color_id
#   puts @current_user.mail
#   if place.save
#     session[:response] = {code: 200, messages: "成功しました"}
#   else
#     session[:response] = {code: 400, messages: place.errors.full_messages}
#   end
#   redirect '/'
# end

post '/newpicture' do
  upload   = params[:photo]
  tempfile = upload[:tempfile]

  # Exifを直接読み取る
  metadata = MiniExiftool.new(tempfile.path, numerical: true)
  
  # puts "=== All EXIF Tags ==="
  # puts metadata.to_hash.inspect
  # puts "======================"


  if metadata.GPSLatitude && metadata.GPSLongitude
  lat = metadata.GPSLatitude    # => 38.254983（例）
  lng = metadata.GPSLongitude   # => 140.330002（例）
  
  puts "GPS: #{lat}, #{lng}"
  else
    puts "GPS情報なし"
    lat = lng = nil
  end
  
  begin
    result = Cloudinary::Uploader.upload(
      tempfile.path,
      resource_type: :auto,
      format:        'jpg',
      quality:       'auto'
    )
    # レスポンス全体をログに出力
    puts "=== Cloudinary Upload Result ==="
    puts result.inspect
    puts "================================="
  rescue => e
    puts "!!! Cloudinary upload error: #{e.class} #{e.message}"
    puts e.backtrace
    result = {}
  end
  # — ここまで追加 —

  photo_url = result['secure_url'] || result[:secure_url]
  puts "=> photo_url: #{photo_url.inspect}"

  place = Place.new(
    place_name:   params[:place_name],
    category_id:  params[:category_id],
    # photo:        photo_url,
    lat:          lat,
    lng:          lng,
    user_id:      User.find(session[:user]).id,
    group_id:     params[:group_id]
  )
  
  place.remote_photo_url = photo_url

  if place.save
    session[:response] = { code: 200, messages: "成功しました" }
  else
    session[:response] = { code: 400, messages: place.errors.full_messages }
  end
  redirect '/'
end

get '/places' do
  content_type :json
  # Placeと関連するUserおよびColorを事前に読み込む
  places = Place.includes(user: :color).all
  if params[:group_id]
    places = places.where(group_id: params[:group_id])
  end
  # JSONに変換する際に、UserとそのColor情報を含める
  json_data = places.to_json(include: { user: { include: :color} })
  json_data
end

get '/signin' do
    erb :sign_in 
end

get '/signup' do
    erb :sign_up
end

post '/signin' do
    user = User.find_by(mail: params[:mail])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
redirect'/'
end

post '/signup' do
    user = User.create(mail: params[:mail],password: params[:password],
    password_confirmation: params[:password_confirmation])
    puts "-----------------"
    if user.persisted?
        puts "aaaaaaaaaa"
        session[:user] = user.id
    end
    redirect '/'
end

get '/signout' do
    session[:user] = nil
    redirect '/'
end

get '/setting' do
    erb :setting
end

post '/color_id' do
  # params[:color] = color_id
  puts "@current_user color_id: #{@current_user.color_id}"
  puts "session[:user]: #{session[:user]}"
  puts "User.find(session[:user]).color_id: #{User.find(session[:user]).color_id}"
  @current_user.color_id = params[:color].to_i
  @current_user.save
  puts "@current_user color_id: #{@current_user.color_id}"
  puts "session[:user]: #{session[:user]}"
  puts "User.find(session[:user]).color_id: #{User.find(session[:user]).color_id}"
  puts User.find(session[:user]).color_id
  redirect '/'
end

get '/list' do
  @places = @current_user.places
  erb :list
end

