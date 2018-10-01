#!/usr/bin/ruby

# Version 1.0
# License Type: GNU GENERAL PUBLIC LICENSE, Version 3
# Author: Marcelo Almeda <marcelomagf@gmail.com>

require 'rubygems'
require 'json'
require 'date'
require 'optparse'

def tagInstanceVolumes(profile,region,instanceid,lftag,tagvalue)
  json =  `aws --profile #{profile} --region #{region} ec2 describe-instances --instance-id #{instanceid}`
  parsed = JSON.parse(json)
  parsed["Reservations"].each do |reservation|
    reservation["Instances"].each  do |instance|
      instance["BlockDeviceMappings"].each do |block|
        volumeid = block["Ebs"]["VolumeId"]
        ecode = system ("aws --profile #{profile} --region #{region} ec2 create-tags --resources #{volumeid} --tags Key=#{lftag},Value=#{tagvalue}")
        if ecode
          puts "Volume #{volumeid} attached to #{instanceid} tagged #{lftag}/#{tagvalue}"
        else
          puts "Volume #{volumeid} attached to #{instanceid} NOT tagged #{lftag}/#{tagvalue}"
        end
      end
    end
  end
end

def listInstances(profile,region,lftag)
  json = `aws --profile #{profile} --region #{region} ec2 describe-instances`
  if json.length > 20
    parsed = JSON.parse(json)
  else
    exit
  end
  tags = Array.new

  # Gotta check if any servers at all
  if json.length > 20
    parsed["Reservations"].each do |reservation|
      reservation["Instances"].each  do |instance|
        if instance["Tags"]
          puts "--> Searching #{lftag} tag on #{instance["InstanceId"]}"
          instance["Tags"].each do |tag|
            if tag["Key"] == lftag 
              tagvalue = tag["Value"]
              tagInstanceVolumes(profile,region,instance["InstanceId"],lftag,tagvalue)
            end
          end
        end
      end
    end
  end
end

# All AWS Regions
regions=[
  "us-east-1",
  "us-east-2",
  "us-west-1",
  "us-west-2",
  "ca-central-1",
  "eu-central-1",
  "eu-west-1",
  "eu-west-2",
  "eu-west-3",
  "ap-northeast-1",
  "ap-northeast-2",
  "ap-southeast-1",
  "ap-southeast-2",
  "ap-south-1",
  "sa-east-1"

]

options = {
  :profile => "default",
  :region => nil,
  :tag => "project",
}

parser = OptionParser.new do|opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on('-p', '--profile profile', 'AWS CLI Profile. Default: "default"') do |profile|
    options[:profile] = profile;
  end
  opts.on('-r', '--region region', 'Region. "all" will list all regions. Default region if not sp
ecified') do |region|
    options[:region] = region;
  end
  opts.on('-t', '--tag tag', 'What tag to look for and tag volumes') do |tag|
    options[:tag] = tag;
  end
  opts.on('-h', '--help', 'Help') do
    puts opts
    exit
  end
end

parser.parse!

regions.each do |region|
  listInstances(options[:profile],region,options[:tag])
end
