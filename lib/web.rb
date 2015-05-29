require 'sinatra'
require 'wup'

get '/?' do
  @files = Wup.redis.smembers("wup:top:files")
  erb :top
end

get '/recent' do
  @files = Wup.redis.lrange("wup:recent:files", 0, 29).uniq
  erb :recent
end

get '/top/add' do #post todo
  Wup.redis.sadd("wup:top:files", params[:wpath])
  redirect back
end

get '/top/remove' do
  Wup.redis.srem("wup:top:files", params[:wpath])
  redirect back
end

get '/wfile/?*' do
  paths = params[:splat]
  wpath = File.join(*paths)

  @is_webroot = wpath == ''
  @path = @is_webroot ? '/' : wpath
  @rpath = File.join(Wup.webroot, wpath) 
  @uppath = File.dirname(@path)
  @uppath = '/' + @uppath unless @uppath == '/'
  
  if @is_dir = File.directory?(@rpath)
    local_request = %w(127.0.0.1).include?(request.ip)
    @files = Wup::FileTool.subfiles(@rpath, (@is_webroot or local_request))
    if @is_webroot and !local_request
      @files.reject!{|d| d =~ /private$/} #config?
    end
    erb :dir
  else
    redis = Wup.redis
    redis.multi do
      redis.lpush("wup:recent:files", @path)
      redis.ltrim("wup:recent:files", 0, 29)
    end

    ext = File.extname(@rpath)
    if params[:raw] or ext =~ /\.(rb|erb|yml|sql)/ or ext == '' #todo from config file
      @body = File.read(@rpath)
      erb :file
    elsif ext =~ /\.(md|markdown)/
      @body = Marker.marker.render(File.read(@rpath))
      erb :markdown
    else
      #html/js/css/txt/img asset file or send for download
      send_file @rpath
    end
  end
end
