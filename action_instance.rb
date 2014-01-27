#!/usr/bin/ruby

# Version 1.0
# License Type: GNU GENERAL PUBLIC LICENSE, Version 3
# Author: Marcelo Almeda <marcelomagf@gmail.com>

require 'rubygems'
require 'json'
require 'optparse'

# Do something with instance
def actionInstance(profile,region,action,instance)
  json = `/usr/local/bin/aws --profile #{profile} --region #{region} ec2 #{action}-instances --instance-ids #{instance}`
  parsed = JSON.parse(json)

  case action
  when "start"
    parsed["StartingInstances"].each do |instance|
      print instance["InstanceId"]
      print ": "
      print instance["PreviousState"]["Name"]
      print " -> "
      print instance["CurrentState"]["Name"]
      print "\n"
    end
  when "stop"
    parsed["StoppingInstances"].each do |instance|
      print instance["InstanceId"]
      print ": "
      print instance["PreviousState"]["Name"]
      print " -> "
      print instance["CurrentState"]["Name"]
      print "\n"
    end
  end
end

options = {
  :action => nil,
  :profile => "default",
  :region => "us-east-1",
  :instaceid => nil,
  :daystokeep => 2,
}

parser = OptionParser.new do|opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on('-a', '--action action', 'Mandatory: "start" or "stop"') do |action|
    options[:action] = action;
  end
  opts.on('-p', '--profile profile', 'AWS CLI Profile. Default: "default"') do |profile|
    options[:profile] = profile;
  end
  opts.on('-r', '--region region', 'Region. Default: "us-east-1"') do |region|
    options[:region] = region;
  end
  opts.on('-i', '--instaceid instaceid', 'Specific instance id') do |instaceid|
    options[:instaceid] = instaceid;
  end
  opts.on('-h', '--help', 'Help') do
    puts opts
    exit
  end
end

parser.parse!

if options[:action].nil? || options[:action].to_s != "start" && options[:action].to_s != "stop"
  puts parser.help
  exit
end

actionInstance(options[:profile],options[:region],options[:action],options[:instanceid])
