#!/usr/bin/ruby

# AWS Regions
regionsfile = __dir__ + "/aws.regions.txt"
regions = File.readlines(regionsfile)

puts regions[0]

regions.each do |r|
  puts r
end
