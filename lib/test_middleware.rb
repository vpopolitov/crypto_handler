class TestMiddleware
  def initialize(app, *args)
    @app = app
    @args = args
    @file_handler = ::ActionDispatch::FileHandler.new('/home/pva/windows_share/custom_flowplayer/site/example-free/files_hd', nil)
  end

  def call(env)
    path = env['PATH_INFO'].chomp('/')
    file_name = File.basename(path)
    case File.extname(file_name)
      when '.m3u8'
        #env['PATH_INFO'] = file_name
        #return @file_handler.call(env)
        return execute(file_name)
      when '.ts'
        #env['PATH_INFO'] = file_name
        #return @file_handler.call(env)
        return execute(file_name)
      else
        return @app.call(env)
      end
    #@file_handler.call(env)
  end

  private

  def execute(file_name)
    #$stderr.puts "test middleware started #{Time.now.strftime('%Y-%m-%d %H:%M:%S:%L')}"
    folder_id = '0B6SbkWXOHDMKa25rQnNSbk9uUlE'

    drive = GoogleApiClient.get_drive
    res = GoogleApiClient.execute api_method: drive.files.list,
                                  parameters: { q: "'#{folder_id}' in parents and title = '#{file_name}'" }

    #$stderr.puts "test middleware before download #{Time.now.strftime('%Y-%m-%d %H:%M:%S:%L')}"
    res = GoogleApiClient.execute uri: res.data.items.first.downloadUrl
    type = case File.extname(file_name)
             when '.m3u8'
               'application/x-mpegurl'
             when '.ts'
               'video/mp2t'
           end
    #$stderr.puts "test middleware finished #{Time.now.strftime('%Y-%m-%d %H:%M:%S:%L')}"
    [200, { 'Content-Type' =>	type }, [res.body]]
  end
end