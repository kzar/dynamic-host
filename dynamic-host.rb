require 'socket'
require 'point'
require 'yaml'
require 'open-uri'

# Load our configuration
config = YAML.load_file('config.yml')

# Sort out domain parts
hostname = config["hostname"].chomp(".")
zonename = hostname.split(".")[1..-1].join(".")
arecord = hostname + "."

# Check our IP address'
host_ip = IPSocket.getaddress(hostname) #rescue ""
if config["external_ip"]
  current_ip = open("http://www.google.co.uk/search?q=what+is+my+ip") do |f|
    /([0-9]{1,3}\.){3}[0-9]{1,3}/.match(f.read).to_s
  end
else
  current_ip =  IPSocket.getaddress(Socket.gethostname).to_s
end

# If our IP address has changed update it
if current_ip and current_ip != host_ip
  # Set up PointHQ credentials
  Point.username = config["point_user"]
  Point.apitoken = config["point_apitoken"]
  # Find our zone (FIXME: Simplify once this makes it https://github.com/atech/point/pull/1 )
  zone = Point::Zone.find(:all).select {|r| r.attributes["name"] == zonename}.first
  # Find our record / create it
  record = zone.records.select do |r|
    r.attributes["name"] == arecord && r.attributes["record_type"] == "A"
  end.first || zone.build_record
  # Update the record
  record.record_type = "A"
  record.name = arecord
  record.data = current_ip
  record.ttl = config["ttl"]
  # And save, throwing exception on problem
  raise Point::Error, record.errors.to_s unless record.save
  # Display result
  puts "Dynamic host #{hostname} sucessfully updated to #{current_ip}"
else
  # Display result
  unless current_ip
    puts "Dynamic host #{hostname} not updated, couldn't find current ip address!"
  else
    puts "Dynamic host #{hostname} is up to date."
  end
end