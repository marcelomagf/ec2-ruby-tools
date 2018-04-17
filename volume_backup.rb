#!/usr/bin/ruby

# Version 1.0
# License Type: GNU GENERAL PUBLIC LICENSE, Version 3
# Author: Marcelo Almeda <marcelomagf@gmail.com>

require 'rubygems'
require 'json'
require 'date'
require 'optparse'

# Scan all volumes and backup each one
def backupAllVolumes(profile,region,daystokeep,name,json,tags)
  parsed = JSON.parse(json)
  parsed["Volumes"].each do |volume|
    backupVolume(profile,region,volume["VolumeId"],daystokeep,name,tags)
  end
end

def listInstanceVolumes(profile,region,instance)
  json =  `aws --profile #{profile} --region #{region} ec2 describe-instances --instance-id #{instance}`
  volumes = Array.new
  parsed = JSON.parse(json)
  parsed["Reservations"].each do |reservation|
    reservation["Instances"].each  do |instance|
      instance["BlockDeviceMappings"].each do |block|
        volumes << block["Ebs"]["VolumeId"]
      end
    end
  end
  return volumes
end

def listVolumes(profile,region)
  json =  `aws --profile #{profile} --region #{region} ec2 describe-volumes`
  tags = Hash.new
  parsed = JSON.parse(json)
  parsed["Volumes"].each do |volume|
    if volume["Tags"]
      volume["Tags"].each do |tag|
        key = tag["Key"]
        value = tag["Value"]
        tags["#{volume["VolumeId"]},#{key}"] = "#{value}" 
      end
    end
  end
  return json,tags
end

# Create a Snapshot
def backupVolume(profile,region,volumeid,daystokeep,name,tags)
  description = ""
  date = Date.today.next_day(daystokeep)
  if name.nil? || name.empty?
    description = "#{volumeid}-deleteafter#{date}"
  else
    description = "#{name}-#{volumeid}-deleteafter#{date}"
  end
  print "Backing up #{volumeid} for #{profile} on #{region}\n"
  json = `aws --profile #{profile} --region #{region} ec2 create-snapshot --volume-id #{volumeid} --description "#{description}"`
  #json = `cat vb.txt`
  parsed = JSON.parse(json)
  snapid = parsed["SnapshotId"]
  tagSnapshot(profile,region,snapid,volumeid,tags)
end

# Tag snapshot with tags from volume
def tagSnapshot(profile,region,snapid,volid,tags)
  tags.each do |k,value|
    kvolid,key = k.split (",")
    if volid == kvolid
      puts "Tagging  #{snapid} from #{volid} with #{key} => #{value}"
      json =  `aws --profile #{profile} --region #{region} ec2 create-tags --resources #{snapid} --tags Key=#{key},Value=#{value}`
    end
  end
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
  :name => nil,
}

parser = OptionParser.new do|opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on('-a', '--action action', 'Mandatory: "backup" or "purge"') do |action|
    options[:action] = action;
  end
  opts.on('-p', '--profile profile', 'AWS CLI Profile. Default: "default"') do |profile|
    options[:profile] = profile;
  end
  opts.on('-r', '--region region', 'Region. Default region if not specified') do |region|
    options[:region] = region;
  end
  opts.on('-v', '--volumeid volumeid', 'Specific volume id to backup') do |volumeid|
    options[:volumeid] = volumeid;
  end
  opts.on('-i', '--instanceid instanceid', 'Backup all volumes attached to an instance') do |instanceid|
    options[:instanceid] = instanceid;
  end
  opts.on('-d', '--days days', 'Days to keep the snapshot. Default: "2"') do |daystokeep|
    options[:daystokeep] = daystokeep;
  end
  opts.on('-n', '--name name', 'Optional name to id snapshot. Default: none') do |name|
    options[:name] = name;
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
  json,tags = listVolumes(options[:profile],options[:region])
  unless options[:volumeid].nil?
    # Just that volume to backup
    backupVolume(options[:profile],options[:region],options[:volumeid],options[:daystokeep].to_i,options[:name],tags)
  else
    unless options[:instanceid].nil?
      # Just that instance to backup
      volumes = listInstanceVolumes(options[:profile],options[:region],options[:instanceid])
      volumes.each do |volume|
        backupVolume(options[:profile],options[:region],volume,options[:daystokeep].to_i,options[:name],tags)
      end
    else
      # All volumes backup
      backupAllVolumes(options[:profile],options[:region],options[:daystokeep].to_i,options[:name],json,tags)
    end
  end
when "purge"
  # Clean 'old' snapshots
  purgeOldSnapshots(options[:profile],options[:region])
end
