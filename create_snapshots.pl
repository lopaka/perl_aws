#!/usr/bin/perl

$| = 1;

use Net::Amazon::EC2;
use YAML::XS qw/LoadFile/;
use POSIX qw/strftime/;

my $config_file = '/usr/local/etc/aws_snapshot.yml';
my $date = strftime "%Y%m%d", localtime;
my $snapshot_id;
my %volumes;
my $volume_id;

# Example of settings YAML file
# ---
# region: us-west-2
# AWSAccessKeyId: ACCESSKEYID
# SecretAccessKey: SECRETKEYID
# volumes:
#   vol-abcdefgh: vol1-description-name
#   vol-12345678: vol2-description-name

my $config = LoadFile($config_file);

my $ec2 = Net::Amazon::EC2->new(
  region => $config->{region},
  AWSAccessKeyId => $config->{AWSAccessKeyId},
  SecretAccessKey => $config->{SecretAccessKey}
);

%volumes = %{$config->{volumes}};

foreach $volume_id (keys(%volumes)) {
  $description = $volumes{$volume_id};
  $snapshot = $ec2->create_snapshot(
                VolumeId => $volume_id,
                Description => "${description}-${date}"
              );
  $ec2->create_tags(
    ResourceId => $snapshot->{snapshot_id},
    Tags => {
      Name => "${description}-${date}"
    }
  );
}
