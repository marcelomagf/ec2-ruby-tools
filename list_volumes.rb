#!/usr/bin/ruby

# Version 1.0
# License Type: GNU GENERAL PUBLIC LICENSE, Version 3
# Author: Marcelo Almeda <marcelomagf@gmail.com>

require 'rubygems'
require 'json'
require 'optparse'

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

# Print each server from all regions
def printRegion(profile,region)
  json = `aws --profile #{profile} --region #{region} ec2 describe-volumes`
  if json.length > 20
    parsed = JSON.parse(json)
  else
    puts "No profile #{profile}. Please run with \"-h\"" 
    exit
  end

  # Gotta check if any servers at all
  if json.length > 20
    puts  "-------------"
    puts "Region: #{region}"
    puts  "-------------"

    parsed["Volumes"].each do |volume|
        print volume["VolumeId"]
        print "\t"
        print volume["Size"]
        print "GB\t"
        print volume["State"]
        print "\t"
        if volume["Attachments"]
          volume["Attachments"].each do |att|
            if att["InstanceId"] =~ /i-/
              print att["InstanceId"]
              print "\t"
              print att["Device"]
            end
          end
        end
        print "\t"
        if volume["Tags"]
          volume["Tags"].each do |tag|
            if tag["Key"] == "Name"
              print tag["Value"]
              printSpaces(tag["Value"],22)
            end
          end
        end
        print "\n"
    end
    puts  "-------------"
  end
end

# All AWS Regions
regions=[
  "us-east-1",
  "us-west-1",
  "us-west-2",
  "eu-west-1",
  "sa-east-1",
  "ap-northeast-1",
  "ap-southeast-1",
  "ap-southeast-2"
]

options = {
  :profile => "default",
  :region => nil,
}

parser = OptionParser.new do|opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on('-p', '--profile profile', 'AWS CLI Profile. Default: "default"') do |profile|
    options[:profile] = profile;
  end
  opts.on('-r', '--region region', 'Region. Default: All regions') do |region|
    options[:region] = region;
  end
  opts.on('-h', '--help', 'Help') do
    puts opts
    exit
  end
end

parser.parse!

# If no regions specified list all volumes from all regions
if options[:region].nil?
  regions.each do |region|
    printRegion(options[:profile],region)
  end
else
  # If any region specified, list volumes for that region only
  printRegion(options[:profile],options[:region])
end
