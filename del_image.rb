#!/usr/bin/ruby

# Version 1.0
# License Type: GNU GENERAL PUBLIC LICENSE, Version 3
# Author: Marcelo Almeda <marcelomagf@gmail.com>

require 'rubygems'
require 'json'
require 'optparse'

# AWS Regions
regionsfile = __dir__ + "/aws.regions.txt"
regions = File.readlines(regionsfile).map(&:chomp)

# Print spaces to tabulate nicely
def printSpaces(name,space)
  if name
    name.size.upto (space) do
      print "\s"
    end
  else
    0.size.upto (space) do
      print "\s"
    end
  end
end

def delImage(profile,imageid)
  json = `aws --profile #{profile} ec2 describe-images --image-ids #{imageid}`
  if json.length > 20
    parsed = JSON.parse(json)
  else
    puts "No profile #{profile}. Please run with \"-h\"" 
    exit
  end

  parsed["Images"].each do |image|
    puts "Removing Image: #{image["Name"]} - #{image["ImageId"]} ..."
    `aws --profile #{profile} ec2 deregister-image --image-id #{imageid}`
    if image["BlockDeviceMappings"]
      image["BlockDeviceMappings"].each do |devblock|
        if devblock["Ebs"]
          puts "Deleting #{devblock["Ebs"]["VolumeSize"]}GB snapshot: #{devblock["Ebs"]["SnapshotId"]}"
          `aws --profile #{profile} ec2 delete-snapshot --snapshot-id #{devblock["Ebs"]["SnapshotId"]}`
        end
      end
    end
  end
end

options = {
  :profile => "default",
  :image => nil,
}

parser = OptionParser.new do|opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on('-p', '--profile profile', 'AWS CLI Profile. Default: "default"') do |profile|
    options[:profile] = profile;
  end
  opts.on('-m', '--imageid imageid', 'Specific image id') do |imageid|
    options[:imageid] = imageid;
  end
  opts.on('-h', '--help', 'Help') do
    puts opts
    exit
  end
end

parser.parse!

if options[:imageid].nil?
  puts parser.help
  exit
end

delImage(options[:profile],options[:imageid])
