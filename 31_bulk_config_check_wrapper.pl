#!/usr/bin/perl
use Cwd;
use File::Find; my $cwd = getcwd();
my $nspepi_dir = "/netscaler"; print "\nEnter Directory of NetScaler config files\n";
chomp (my $conf_dir = <STDIN>); print "\n";
my $ns_conf_file;
my $ns_conf;
my @ns_conf_files;
my @responses;
chdir "$conf_dir/";
find(
     sub{ 
         -f $_ && $_ =~ /.*conf/&& push @ns_conf_files,$File::Find::name
     }, "."
); 
foreach $ns_conf_file(@ns_conf_files){
    if( $ns_conf_file =~ /^\.\/(.*)/i )
    {
        $ns_conf_file = $1;
    }
    my $response = `$nspepi_dir/check_invalid_config $conf_dir/$ns_conf_file 2>&1`;
    push @nspepi_responses, $ns_conf_file.$response;
} open (NSPEPIOUT, "> ./config_status.txt") or die "Cannot open config_status.txt for writing \n";
print NSPEPIOUT "\n";
foreach $nspepi_response(@nspepi_responses){
    $nspepi_response =~ s/The nspepi.*?version\.//g;
    print NSPEPIOUT "$nspepi_response\n";
}
print "\n\nScript has completed. Report is here: $conf_dir/config_status.txt\n\n";