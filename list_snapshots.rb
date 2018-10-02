#!/usr/bin/ruby

# Version 1.0
# License Type: GNU GENERAL PUBLIC LICENSE, Version 3
# Author: Marcelo Almeda <marcelomagf@gmail.com>

require 'rubygems'
require 'json'
require 'optparse'

# AWS Regions
regionsfile = __dir__ + "/aws.regions.txt"
regions = File.readlines(regionsfile)

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
    json = `aws --profile #{profile} ec2 describe-snapshots --owner-ids self`
  else
    json = `aws --profile #{profile} --region #{region} ec2 describe-snapshots --owner-ids self`
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

    total=0

    parsed["Snapshots"].each do |snap|
      print snap["SnapshotId"]
      print "\t"
      print snap["VolumeId"]
      print "\t"
      print snap["StartTime"].split("T")[0]
      print "\t"
      total=total+snap["VolumeSize"].to_i
      print snap["VolumeSize"]
      print "GB"
      print "\t"
      print snap["Description"]
      print "\n"
    end
    puts  "-------------"
    if total > 1024
      total = total / 1024
      puts "Total: #{total}TB"
    else
      puts "Total: #{total}GB"
    end
    puts  "-------------"
  end
end

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
