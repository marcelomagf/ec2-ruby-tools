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

# Print each server from all regions
def printRegion(profile,region)
  if region == "default"
    json = `aws --profile #{profile} ec2  describe-images --owners self`
  else
    json = `aws --profile #{profile} --region #{region} ec2  describe-images --owners self`
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

    parsed["Images"].each do |image|
      print image["ImageId"]
      print "\t"
      print image["CreationDate"].split("T")[0]
      print "\t"
      if image["Platform"]
        print image["Platform"]
      else
        print "linux"
      end
      print "\t"
      print image["Name"]
      printSpaces(image["Name"],30)
      if image["BlockDeviceMappings"]
        image["BlockDeviceMappings"].each do |devblock|
          if devblock["Ebs"]
            print devblock["Ebs"]["VolumeSize"]
            print "GB: "
            print devblock["Ebs"]["SnapshotId"]
            print " "
          end
        end
      end
      print "\n"
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
