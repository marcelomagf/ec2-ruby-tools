# ec2-ruby-tools

This is a set of quite simple ruby script to make easier to use the [AWS CLI](http://aws.amazon.com/cli/) Mostly inspired from Colin Johnson's [AWS missing tools](https://github.com/colinbjohnson/aws-missing-tools)

```
AWS CLI supports profiles on ~/.aws/config file:

  [profile myprofilename]
  region = us-east-1
  aws_access_key_id = AKAKAKAKAKAKAKAKAKAK
  aws_secret_access_key = 1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
```

## list_instances.rb

List all instances from all regions or for a specified region

```
  Usage: ./list_instances.rb [options]
    -p, --profile profile            AWS CLI Profile. Default: "default"
    -r, --region region              Region. Default: All regions
    -h, --help                       Help
```

## volume_backup.rb

Create backup snapshots of a single volume or all volumes from a region.

```
Usage: ./volume_backup.rb [options]
    -a, --action action              Mandatory: "backup" or "purge"
    -p, --profile profile            AWS CLI Profile. Default: "default"
    -r, --region region              Region. Default: "us-east-1"
    -i, --volumeid volumeid          Specific volume id to backup
    -d, --days days                  Days to keep the snapshot. Default: "2"
    -h, --help                       Help
```

Crontab schedule for a 2 days backup snapshots:

````
50 23 * * * /path/volume_backup.rb -a backup -p myprofile -r us-west-1 -d 2
55 23 * * * /path/volume_backup.rb -a purge -p myprofile -r us-west-1
```

## action_instance.rb

```
Usage: ./action_instance.rb [options]
    -a, --action action              Mandatory: "start" or "stop"
    -p, --profile profile            AWS CLI Profile. Default: "default"
    -r, --region region              Region. Default: "us-east-1"
    -i, --instaceid instaceid        Specific instance id
    -h, --help                       Help
```
