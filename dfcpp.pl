#!/usr/bin/perl

sub process_cpanfile {
  my $str;
  open(my $fh, '<:encoding(UTF-8)', 'cpanfile') or die "Could not open cpanfile: $!";
  while (my $row = <$fh>) {
    chomp $row;
    $row =~ s/^requires\s+\'([A-Za-z0-9:]+)';/$1/;
    print "# cpanfile : found module : ".$row."\n";
    $row = 'RUN cpanm '.$row."\n";
    $str.= $row;
  }
  close $fh;
  return $str;
}

# remove '&& \' from the end of each strin
# e.g.
sub remove_chain {
  my $str_num = shift;
  $cmd = 'sed -i \''.$str_num.'s/&& \\\\$//\' Dockerfile';
  print $cmd."\n";
  system($cmd);
}

# add 'RUN ' in beginning of specified string
sub add_run {
  my $str_num = shift;
  system('sed -i \''.$str_num.'s/^/RUN /\' Dockerfile');
}



open(my $fh, '<:encoding(UTF-8)', 'Dockerfile') or die "Could not open Dockerfile: $!";
my $str='';
while (my $row = <$fh>) {
  if ($row =~ /cpanm\s+--installdeps/) {
    $str.= process_cpanfile();
  } else {
    $str.= $row;
  }
}
close $fh;
# print $str; # if debug

open(my $fh, '>', 'Dockerfile');
print $fh $str;
close $fh;

my $first_cpanm_str_num = `grep -n -m 1 "RUN cpanm" Dockerfile | cut -f1 -d: | xargs echo -n`;
my $last_cpanm_str_num = `grep -n "RUN cpanm" Dockerfile  | tail -1 | cut -f1 -d: | xargs echo -n`;

remove_chain($first_cpanm_str_num-1);
add_run($last_cpanm_str_num+1);
