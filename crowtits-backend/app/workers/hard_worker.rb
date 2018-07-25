require 'sidekiq'
# require 'sidekiq/web'
require 'json'
require 'httparty'
require 'sidekiq-scheduler'


#this is an initializer
Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://127.0.0.1:6379' }
end

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://127.0.0.1:6379' }
end

class HardWorker
  include Sidekiq::Worker


  def perform
    # executes jobs
    p "------------------------------------------------------------------------------------------"
    current_notification_from_database = {}
    seen_in_new_response = {}
    # all_notifications = Notification.find_by({now_playing: true})
    all_notifications = {}
    # assuming database object thing is ordered by station_name: { data }
    all_notifications.each do |k, v|
      current_notification_from_database[k] = v
      seen_in_new_response[k] = false
    end

    url = "http://api.dar.fm/playlist.php?q=drake&partner_token=2628583291"
    xmlresponse = HTTParty.get(url)
    jsonresponse = Hash.from_xml(xmlresponse.body)
    stations = jsonresponse['playlist']['station']

    if stations.class == Hash
      stations = [stations]
    end

    stations.each do |el|
      p el['callsign'].strip 
      if current_notification_from_database[el['callsign'].strip]
        next
      else
        p
        # station_info = Station.find_by(el['callsign'].strip)
        # return {1: {}}
        # notification = Notification.new({
        #   song_title: el['title'].strip,
        #   channel_name: el['callsign'].strip,
        #   # station_id: station_info.id
        #   now_playing: true
        #   })
        # save @notification.save will happen in the create function of notifications controller
      end
      seen_in_new_response[el['callsign'].strip] = true
    end
    # p Notifications.all
  end

end
