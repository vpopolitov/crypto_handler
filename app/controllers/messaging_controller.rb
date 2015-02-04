class MessagingController < ApplicationController
  def send_message
    #send_file '/home/pva/Downloads/inhibited-island.mp4', stream: true
    send_file 'public/inhibited-island.mp4', :stream => true, :disposition => 'inline'
  end
end
