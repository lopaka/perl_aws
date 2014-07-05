#!/usr/bin/perl

$| = 1;

use Net::Amazon::EC2;
use YAML::XS qw/LoadFile/;
use POSIX qw/strftime/;

my $date = strftime "%Y%m%d", localtime;
my $snapshot_id;
my $config = LoadFile('.settings.yml');
my %volumes;
my $volume_id;

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
                Description => $description
              );
  $ec2->create_tags(
    ResourceId => $snapshot->{snapshot_id},
    Tags => {
      Name => "${description}-${date}"
    }
  );
}
