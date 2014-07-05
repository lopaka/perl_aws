#!/usr/bin/perl

$| = 1;

use Net::Amazon::EC2;
use YAML::XS qw/LoadFile/;
use POSIX qw/strftime/;

my $date = strftime "%Y%m%d", localtime;
my $snapshot_id;
my $config = LoadFile('.settings.yml');

my $ec2 = Net::Amazon::EC2->new(
  region => $config->{region},
  AWSAccessKeyId => $config->{AWSAccessKeyId},
  SecretAccessKey => $config->{SecretAccessKey}
);

#%volumes = (
#  'linux-lvm-1of4' => 'vol-12345678',
#  'linux-lvm-2of4' => 'vol-abcdefgh',
#  'linux-lvm-3of4' => 'vol-1a2b3c4d',
#  'linux-lvm-4of4' => 'vol-a1b2c3d4'
#  );

$snapshot = $ec2->create_snapshot( VolumeId => 'vol-12345678', Description => 'linux-lvm-1of4' );
$ec2->create_tags( ResourceId => $snapshot->{snapshot_id}, Tags => {Name => "linux-lvm-1of4-${date}"} );
