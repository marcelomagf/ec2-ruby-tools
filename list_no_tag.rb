#!/usr/bin/ruby

# Version 1.0
# License Type: GNU GENERAL PUBLIC LICENSE, Version 3
# Author: Marcelo Almeda <marcelomagf@gmail.com>

# Requires
require 'rubygems'
require 'json'
require 'optparse'

# AWS Regions
regionsfile = __dir__ + "/aws.regions.txt"
regions = File.readlines(regionsfile).map(&:chomp)

# Print AWS Service Label
def printLabel(label)
  puts  "-------------"
  puts  label
  puts  "-------------"
end

# Print EMR
def printEMR(profile,region,lftag)
  json = `aws --profile #{profile} --region #{region} emr list-clusters --active`
  if json.length > 20
    parsed = JSON.parse(json)
  end
  if json.length > 20
    parsed["Clusters"].each do |emr|
      clusterid = emr["Id"]
      clustername = emr["Name"]
      jsonb = `aws --profile #{profile} --region #{region} emr describe-cluster --cluster-id #{clusterid} --query Cluster.Tags 2> /dev/null`
      if jsonb.length > 20
        parsedb = JSON.parse(jsonb)
      else
        puts "emr sem tag: #{clustername} #{region}"
      end
      if jsonb.length > 20
        ok = false
        parsedb.each do |tag|
          if tag["Key"] == lftag
            ok = true
          end
        end
        if !ok
          puts "emr sem tag: #{emrname} #{region}"
        end
      end
    end
  end
end

# Print RDS
def printRDS(profile,region,lftag)
  json = `aws --profile #{profile} --region #{region} rds describe-db-instances`
  if json.length > 20
    parsed = JSON.parse(json)
  end
  if json.length > 20
    parsed["DBInstances"].each do |rds|
      arn = rds["DBInstanceArn"]
      rdsname = rds["DBInstanceIdentifier"]
      jsonb = `aws --profile #{profile} --region #{region} rds list-tags-for-resource --resource-name  #{arn} 2> /dev/null`
      if jsonb.length > 20
        parsedb = JSON.parse(jsonb)
      else
        puts "rds sem tag: #{rdsname} #{region}"
      end
      if jsonb.length > 20
        ok = false
        parsedb["TagList"].each do |tag|
          if tag["Key"] == lftag
            ok = true
          end
        end
        if !ok
          puts "rds sem tag: #{rdsname} #{region}"
        end
      end
    end
  end
end

# Print Lambda
def printLambda(profile,region,lftag)
  json = `aws --profile #{profile} --region #{region} lambda list-functions`
  if json.length > 20
    parsed = JSON.parse(json)
  end
  if json.length > 20
    parsed["Functions"].each do |lambda|
      lambdaname= lambda["FunctionName"]
      lambdaarn= lambda["FunctionArn"]
      jsonb = `aws --profile #{profile} --region #{region} lambda list-tags --resource #{lambdaarn} 2> /dev/null`
      if jsonb.length > 20
        parsedb = JSON.parse(jsonb)
      else
        puts "Lambda sem tag: #{lambdaname}"
      end
      if jsonb.length > 20
        ok = false
        parsedb["Tags"].each do |tag|
          if tag == lftag
            ok = true
          end
        end
        if !ok
          puts "lambda sem tag: #{lambdaname}"
        end
      end
    end
  end
end

# Print S3 Buckets
def printBuckets(profile,region,lftag)
  json = `aws --profile #{profile} --region #{region} s3api list-buckets`
  if json.length > 20
    parsed = JSON.parse(json)
  end
  if json.length > 20
    parsed["Buckets"].each do |bucket|
      bucketname= bucket["Name"]
      jsonb = `aws --profile #{profile} --region #{region} s3api get-bucket-tagging --bucket #{bucketname} 2> /dev/null`
      if jsonb.length > 20
        parsedb = JSON.parse(jsonb)
      else
        puts "Bucket sem tag: #{bucketname}"
      end
      if jsonb.length > 20
        ok = false
        parsedb["TagSet"].each do |tag|
          if tag["Key"] == lftag
            ok = true
          end
        end
        if !ok
          puts "Bucket sem tag: #{bucketname}"
        end
      end
    end
  end
end

# Print Cloudformation
def printCloudformation(profile,region,lftag)
  json = `aws --profile #{profile} --region #{region} cloudformation describe-stacks`
  if json.length > 20
    parsed = JSON.parse(json)
  end
  # Gotta check if any servers at all
  if json.length > 20
    parsed["Stacks"].each do |cloudformation|
      name = cloudformation["StackName"]
      ok = false
      if cloudformation["Tags"]
        cloudformation["Tags"].each do |tag|
          if tag["Key"] == lftag
            project = tag["Value"]
            ok = true
          end
        end
      end
      if !ok
        puts "Stack sem tag: #{name} #{region}"
      end
    end
  end
end

# Print Volumes
def printVolumes(profile,region,lftag)
  json = `aws --profile #{profile} --region #{region} ec2 describe-volumes`
  if json.length > 20
    parsed = JSON.parse(json)
  end
  # Gotta check if any servers at all
  if json.length > 20
    parsed["Volumes"].each do |volume|
      name = volume["VolumeId"]
      ok = false
      if volume["Tags"]
        volume["Tags"].each do |tag|
          if tag["Key"] == lftag
            project = tag["Value"]
            ok = true
          end
        end
      end
      if !ok
        puts "Volume sem tag: #{name} #{region}"
      end
    end
  end
end

# Print Snapshots
def printSnapshots(profile,region,lftag)
  json = `aws --profile #{profile} --region #{region} ec2 describe-snapshots --owner-ids self`
  if json.length > 20
    parsed = JSON.parse(json)
  end
  # Gotta check if any servers at all
  if json.length > 20
    parsed["Snapshots"].each do |snapshot|
      name = snapshot["SnapshotId"]
      ok = false
      if snapshot["Tags"]
        snapshot["Tags"].each do |tag|
          if tag["Key"] == lftag
            project = tag["Value"]
            ok = true
          end
        end
      end
      if !ok
        puts "Snapshot sem tag: #{name} #{region}"
      end
    end
  end
end

# Print Redshift
def printRedshift(profile,region,lftag)
  json = `aws --profile #{profile} --region #{region} redshift describe-clusters`
  if json.length > 20
    parsed = JSON.parse(json)
  end
  # Gotta check if any servers at all
  if json.length > 20
    parsed["Clusters"].each do |redshift|
      name = redshift["ClusterIdentifier"]
      ok = false
      if redshift["Tags"]
        redshift["Tags"].each do |tag|
          if tag["Key"] == lftag
            project = tag["Value"]
            ok = true
          end
        end
      end
      if !ok
        puts "Redshift sem tag: #{name} #{region}"
      end
    end
  end
end

# Print EC2 Instances
def printInstances(profile,region,lftag)
  json = `aws --profile #{profile} --region #{region} ec2 describe-instances`
  if json.length > 20
    parsed = JSON.parse(json)
  end

  # Gotta check if any servers at all
  if json.length > 20
    parsed["Reservations"].each do |reservation|
      name = "no name "
      project = "no project "
      reservation["Instances"].each  do |instance|
        if instance["Tags"]
          instance["Tags"].each do |tag|
            if tag["Key"] == "Name"
              name = tag["Value"]
            end
            if tag["Key"] == lftag
              project = tag["Value"]
            end
          end
        end
        if project == "no project "
          puts "EC2 sem tag: #{name} #{region} #{instance["InstanceId"]}"
        end
      end
    end
  end
end


options = {
  :instance => false,
  :rds => false,
  :emr => false,
  :s3 => false,
  :redshift => false,
  :lambda => false,
  :cloudformation => false,
  :tag => "project",
  :profile => "default",
}

parser = OptionParser.new do|opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on('-i', '--instance', 'List Instances') do |instance|
    options[:instance] = true;
  end
  opts.on('-d', '--rds', 'List RDS') do |rds|
    options[:rds] = true;
  end
  opts.on('-e', '--emr', 'List EMR') do |emr|
    options[:emr] = true;
  end
  opts.on('-f', '--redshift', 'List Redshift') do |redshift|
    options[:redshift] = true;
  end
  opts.on('-s', '--s3', 'List S3 Buckets') do |s3|
    options[:s3] = true;
  end
  opts.on('-l', '--lambda', 'List Lambda Functions') do |lambda|
    options[:lambda] = true;
  end
  opts.on('-c', '--cloudformation', 'List Cloudformation Stacks') do |cloudformation|
    options[:cloudformation] = true;
  end
  opts.on('-t', '--tag tag', 'What tag to look for') do |tag|
    options[:tag] = tag;
  end
  opts.on('-r', '--region region', 'AWS Specific Region. Default: "default"') do |region|
    options[:region] = region;
  end
  opts.on('-p', '--profile profile', 'AWS CLI Profile. Default: "default"') do |profile|
    options[:profile] = profile;
  end
  opts.on('-h', '--help', 'Help') do
    puts opts
    exit
  end
end

parser.parse!

if options[:region]
  regions=[
    "#{options[:region]}",
  ]
end

if options[:instance]
  printLabel("EC2")
  regions.each do |region|
    printInstances(options[:profile],region,options[:tag])
    printVolumes(options[:profile],region,options[:tag])
    printSnapshots(options[:profile],region,options[:tag])
  end
end

if options[:rds]
  printLabel("RDS")
  regions.each do |region|
    printRDS(options[:profile],region,options[:tag])
  end
end

if options[:emr]
  printLabel("EMR")
  regions.each do |region|
    printEMR(options[:profile],region,options[:tag])
  end
end

if options[:redshift]
  printLabel("Redshift")
  regions.each do |region|
    printRedshift(options[:profile],region,options[:tag])
  end
end

if options[:cloudformation]
  printLabel("Cloudformation")
  regions.each do |region|
    printCloudformation(options[:profile],region,options[:tag])
  end
end

if options[:s3]
  printLabel("Buckets")
  printBuckets(options[:profile],"us-east-1",options[:tag])
end

if options[:lambda]
  printLabel("Lambda Function")
  printLambda(options[:profile],"us-east-1",options[:tag])
end
