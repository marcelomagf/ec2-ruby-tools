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
  json = `aws --profile #{profile} --region #{region} ec2 describe-snapshots --owner-ids self`
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

    totalsize=0
    parsed["Snapshots"].each do |snap|
      print snap["SnapshotId"]
      print "\t"
      print snap["VolumeId"]
      print "\t"
      print snap["StartTime"].split("T")[0]
      print "\t"
      totalsize=totalsize+snap["VolumeSize"].to_i
      print snap["VolumeSize"]
      print "GB"
      print "\t"
      print snap["Description"]
      print "\n"
    end
    puts "-------------"
    puts "Total size: #{totalsize} GB"
    puts "-------------"
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
