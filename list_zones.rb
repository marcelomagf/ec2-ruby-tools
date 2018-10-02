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
    print name
    name.size.upto (space) do
      print "\s"
    end
  else
    0.size.upto (space) do
      print "\s"
    end
  end
end

# Gotta grab all zone ids and names 
def getZoneIds(profile)
  zones = Array.new
  zonenames = Hash.new
  zonenamestemp = Hash.new
  json = `aws --profile #{profile}  route53 list-hosted-zones`
  if json.length > 20
    parsed = JSON.parse(json)
  else
    puts "No profile #{profile}. Please run with \"-h\""
    exit
  end
  # Gotta check if any servers at all
  if json.length > 20
    parsed["HostedZones"].each do |zone|
      zones << zone["Id"].split("/").last
      zonenamestemp = { zone["Id"].split("/").last => zone["Name"] }
      zonenames.merge!(zonenamestemp)
    end
  end
  return zones, zonenames
end

# Print zone/domains/recordsets
def printZone(profile,zoneid,zonename)
  json = `aws --profile #{profile} route53 list-resource-record-sets --hosted-zone-id #{zoneid}`
  if json
    parsed = JSON.parse(json)
  end
  puts "------------------------"
  puts "Dominio: #{zonename}"
  puts "------------------------"
  # Gotta check if anything
  if json.length > 20
    parsed["ResourceRecordSets"].each do |rrt|
      printSpaces(rrt["Name"].chomp("."),38)
      printSpaces(rrt["Type"],6)
      # Gotta check if anything
      if rrt["ResourceRecords"]
        rrt["ResourceRecords"].each do |val|
          print val["Value"]
        end
      end
      print "\n"
    end
  end
  puts "------------------------"
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
  opts.on('-h', '--help', 'Help') do
    puts opts
    exit
  end
end

parser.parse!

zones,zonenames = getZoneIds(options[:profile])
zones.each do |zoneid|
  zonename = zonenames[zoneid].chomp(".")
  printZone(options[:profile],zoneid,zonename)
end
