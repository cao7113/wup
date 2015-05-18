require 'sinatra'
require 'wup'

get '/most' do
  Wup.redis.keys("wup:most:used:*")
end

get '/recent' do
  @files = Wup.redis.lrange("wup:recent:files", 0, 50).uniq
  erb :recent
end

get '/?*' do
  paths = params[:splat]
  wpath = File.join(*paths)

  @is_webroot = wpath == ''
  @path = @is_webroot ? '/' : wpath
  @rpath = File.join(Wup.webroot, wpath) 
  @uppath = File.dirname(@path)
  @uppath = '/' + @uppath unless @uppath == '/'
  
  if @is_dir = File.directory?(@rpath)
    @files = Wup::FileTool.subfiles(@rpath, @is_webroot)
    erb :dir
  else
    #Wup.redis.incr("wup:most:used:#{@path}")
    Wup.redis.lpush("wup:recent:files", @path)

    ext = File.extname(@rpath)
    if ext =~ /\.(md|markdown)/
      @body = Marker.marker.render(File.read(@rpath))
      erb :markdown
    elsif ext =~ /\.(rb|erb|yml)/ or ext == '' #todo from config file
      @body = File.read(@rpath)
      erb :file
    else
      #html/js/css/txt/img asset file or send for download
      send_file @rpath
    end
  end
end
