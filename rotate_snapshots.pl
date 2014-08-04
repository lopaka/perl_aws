#!/usr/bin/perl

$| = 1;

use Net::Amazon::EC2;
use YAML::XS qw/LoadFile/;
use POSIX qw/strftime/;

my $config_file = '/usr/local/scripts/ec2/.settings.yml';
my $snapshot_id;
my $snapshot_date;
my $config = LoadFile($config_file);
my %volumes = %{$config->{volumes}};
my $ownerid = $config->{OwnerID};
my @sorted;
my $keep_counter;

my %snapshot_volume_ids;

my $ec2 = Net::Amazon::EC2->new(
  region => $config->{region},
  AWSAccessKeyId => $config->{AWSAccessKeyId},
  SecretAccessKey => $config->{SecretAccessKey}
);

$snapshots = $ec2->describe_snapshots(Owner => $ownerid);
foreach $snapshot (@$snapshots) {
  # print "Snapshot description: " . $snapshot->description . "\n";
  # print "Snapshot ID:          " . $snapshot->snapshot_id . "\n";
  # print "Volume_id snapshot:   " . $snapshot->volume_id . "\n";
  # print "Snapshot Start Time: " . $snapshot->start_time . "\n";

  # Place each snapshot into array which is in hash with volume_id as key - hash of arrays.
  # Each entry is start time<tab>snapshot_id to easily sort via time.
  push(@{$snapshot_volume_ids{$snapshot->volume_id}}, $snapshot->start_time . "\t" . $snapshot->snapshot_id);
}

foreach $snapshot_volume_id (keys(%volumes)) {
  # reset counter
  $keep_counter = 60;

  print $snapshot_volume_id . " " . $volumes{$snapshot_volume_id} . "\n";

  # Sort snapshots by date taken (start_time) most recent on top 
  @sorted = sort {$b cmp $a} (@{$snapshot_volume_ids{$snapshot_volume_id}});

  foreach $snapshot (@sorted) {
    if ($keep_counter > 0) {
      print "$keep_counter $snapshot\n";
      $keep_counter--;
    }
    else {
      ($snapshot_date, $snapshot_id) = split(/\t/,$snapshot);
      print "DELETING snapshot of $volumes{$snapshot_volume_id} - $snapshot_date ID=$snapshot_id - ";
      $delete_snapshot = $ec2->delete_snapshot(SnapshotId => $snapshot_id);
      if ($delete_snapshot) {
        print "DONE\n"
      }
      else {
        die "FAILED DELETION"
      }
    }
  }
}
