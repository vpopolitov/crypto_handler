class MessagingController < ApplicationController
  def send_message
    send_file '/home/pva/Downloads/inhibited-island.mp4', stream: true
  end
end
