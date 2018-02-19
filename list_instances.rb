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
  if region == "default"
    json = `aws --profile #{profile} ec2 describe-instances`
  else
    json = `aws --profile #{profile} --region #{region} ec2 describe-instances`
  end
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

    parsed["Reservations"].each do |reservation|
      reservation["Instances"].each  do |instance|
        if instance["Tags"]
          instance["Tags"].each do |tag|
            if tag["Key"] == "Name"
              print tag["Value"]
              printSpaces(tag["Value"],30)
            end
          end
        end
        print instance["InstanceId"]
        print "\t"
        print instance["State"]["Name"]
        print "\t"
        print instance["InstanceType"]
        print "\t"
        if instance["Platform"]
          print instance["Platform"]
        else
          print "linux"
        end
        print "\t"
        print instance["Placement"]["AvailabilityZone"]
        print "\t"
        print instance["PrivateIpAddress"]
        print "\t"
        print instance["PublicIpAddress"]
        print "\n"
      end
    end
    puts  "-------------"
  end
end

# All AWS Regions
regions=[
  "us-east-1",
  "us-west-2",
  "us-west-1",
  "sa-east-1",
  "eu-west-1",
  "eu-central-1",
  "ap-southeast-1",
  "ap-northeast-1",
  "ap-southeast-2",
  "ap-northeast-2"
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
  opts.on('-r', '--region region', 'Region. "all" will list all regions. Default region if not specified') do |region|
    options[:region] = region;
  end
  opts.on('-h', '--help', 'Help') do
    puts opts
    exit
  end
end

parser.parse!

# If no regions specified go for default 
if options[:region].nil?
  printRegion(options[:profile],"default")

  # List all regions
elsif options[:region] == "all"
  regions.each do |region|
    printRegion(options[:profile],region)
  end
else
  # If any region specified, list instances for that region only
  printRegion(options[:profile],options[:region])
end
