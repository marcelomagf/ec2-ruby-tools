#!/usr/bin/ruby

# Version 1.0
# License Type: GNU GENERAL PUBLIC LICENSE, Version 3
# Author: Marcelo Almeda <marcelomagf@gmail.com>

require 'rubygems'
require 'json'
require 'date'
require 'optparse'

# Scan all volumes and backup each one
def backupAllVolumes(profile,region,daystokeep)
  json =  `aws --profile #{profile} --region #{region} ec2 describe-volumes`
  parsed = JSON.parse(json)
  parsed["Volumes"].each do |volume|
    backupVolume(profile,region,volume["VolumeId"],daystokeep)
  end
end

# Create a Snapshot
def backupVolume(profile,region,volumeid,daystokeep)
  date = Date.today.next_day(daystokeep)
  print "Backing up #{volumeid} for #{profile} on #{region}\n"
  `aws --profile #{profile} --region #{region} ec2 create-snapshot --volume-id #{volumeid} --description "#{volumeid}-deleteafter#{date}"`
end

# Delete all expired snapshots
def purgeOldSnapshots(profile,region)
  json =  `aws --profile #{profile} --region #{region} ec2 describe-snapshots --owner-ids self`
  parsed = JSON.parse(json)
  parsed["Snapshots"].each do |snapshot|
    desc = snapshot["Description"]
    snapid = snapshot["SnapshotId"]
    if desc.to_s.match('deleteafter')
      deletedate = desc.to_s.split('-deleteafter').last
      vol = desc.to_s.split('-deleteafter').first
      if Date.strptime(deletedate, "%Y-%m-%d") < Date.today
        puts "Deleting #{snapid} for volume #{vol}- Due date: #{deletedate}"
        `aws --profile #{profile} --region #{region} ec2 delete-snapshot --snapshot-id #{snapid}`
      end
    end
  end
end

options = {
  :action => nil,
  :profile => "default",
  :region => "us-east-1",
  :volumeid => nil,
  :daystokeep => 2,
}

parser = OptionParser.new do|opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on('-a', '--action action', 'Mandatory: "backup" or "purge"') do |action|
    options[:action] = action;
  end
  opts.on('-p', '--profile profile', 'AWS CLI Profile. Default: "default"') do |profile|
    options[:profile] = profile;
  end
  opts.on('-r', '--region region', 'Region. Default: "us-east-1"') do |region|
    options[:region] = region;
  end
  opts.on('-i', '--volumeid volumeid', 'Specific volume id to backup') do |volumeid|
    options[:volumeid] = volumeid;
  end
  opts.on('-d', '--days days', 'Days to keep the snapshot. Default: "2"') do |region|
    options[:daystokeep] = region;
  end
  opts.on('-h', '--help', 'Help') do
    puts opts
    exit
  end
end

parser.parse!

if options[:action].nil? || options[:action].to_s != "backup" && options[:action].to_s != "purge"
  puts parser.help
  exit
end

case options[:action]
when "backup"
  unless options[:volumeid].nil?
    # Just that volume to backup
    backupVolume(options[:profile],options[:region],options[:volumeid],options[:daystokeep].to_i)
  else
    # All volumes backup
    backupAllVolumes(options[:profile],options[:region],options[:daystokeep].to_i)
  end
when "purge"
  # Clean 'old' snapshots
  purgeOldSnapshots(options[:profile],options[:region])
end
