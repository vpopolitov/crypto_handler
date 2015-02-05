class MessagingController < ApplicationController
  include ActionController::Live
  
  FILE_NAME = 'public/inhibited-island.mp4'
  CHUNK_SIZE = 100_000
  
  def send_message
    #send_file FILE_NAME, :stream => true, :disposition => 'inline'
    
    File.open(FILE_NAME) do |f|
      #send_data(f.read)
      
      buffer = ''
      while buffer = f.read(CHUNK_SIZE)
        response.stream.write buffer
      end
    end
    
    response.stream.close
  end
end
