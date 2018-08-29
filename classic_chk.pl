#!/usr/bin/perl -w
#
# version: 8/28/2018
#
# This program searches a NetScaler configuration file and prefixes
# lines with 3 greater than symbols >>> where configuration commands 
# contain classic policies.  
# Use this output to identify the extent to which convesion to
# advanced policies will be necessary.
#      
# COPYRIGHT
# This sample code is provided to you as is with no representations, 
# warranties or conditions of any kind. You may use, modify and 
# distribute it at your own risk. CITRIX DISCLAIMS ALL WARRANTIES 
# WHATSOEVER, EXPRESS, IMPLIED, WRITTEN, ORAL OR STATUTORY, INCLUDING 
# WITHOUT LIMITATION WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE, TITLE AND NONINFRINGEMENT. Without limiting the 
# generality of the foregoing, you acknowledge and agree that (a) 
# the sample code may exhibit errors, design flaws or other problems, 
# possibly resulting in loss of data or damage to property; (b) it may 
# not be possible to make the sample code fully functional; and 
# (c) Citrix may, without notice or liability to you, cease to make 
# available the current version and/or any future versions of the sample 
# code. In no event should the code be used to support ultra-hazardous 
# activities, including but not limited to life support or blasting 
# activities. NEITHER CITRIX NOR ITS AFFILIATES OR AGENTS WILL BE LIABLE,
# UNDER BREACH OF CONTRACT OR ANY OTHER THEORY OF LIABILITY, FOR ANY 
# DAMAGES WHATSOEVER ARISING FROM USE OF THE SAMPLE CODE, INCLUDING 
# WITHOUT LIMITATION DIRECT, SPECIAL, INCIDENTAL, PUNITIVE, CONSEQUENTIAL 
# OR OTHER DAMAGES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. 
# Although the copyright in the code belongs to Citrix, any distribution 
# of the sample code should include only your own standard copyright 
# attribution, and not that of Citrix. You agree to indemnify and defend 
# Citrix against any and all claims arising from your use, modification 
# or distribution of the sample code.

use v5.14.2;
use Getopt::Std;
use charnames ':loose';
use strict;

my (
    $warnings,
    @CLASSIC_EXPR,
    %options,
    $file_in,
    $file_out,
    @nsconf,
    $warn,
) = 0;

# load classic expressions					
foreach (<DATA>) {								
	chomp($_);
	push(@CLASSIC_EXPR, $_);
}

# sort expressions to increase specificity
@CLASSIC_EXPR = sort { length($a) <=> length($b) } @CLASSIC_EXPR;

# Get CLI options
getopts("hi:o:", \%options);	
exists($options{'h'}) ? (&HELP_MESSAGE) : ();
$#ARGV lt 0 ? (&HELP_MESSAGE) : ();	

$file_in = $ARGV[0];
if (defined $ARGV[1]) { 
        $file_out = $ARGV[1] 
} else { 
        $file_out = $ARGV[0].'.audit.conf' 
}		


# open input file
open(INFILE, '<', $file_in) or die "Can't open infile $file_in: $!\n";	
@nsconf = <INFILE>;
close INFILE;
print "$file_in is ", scalar(@nsconf), " lines. \n";

# open out file
open(OUTFILE,'>', $file_out) or die "Can't open outfile $file_out: $!\n";
binmode(OUTFILE, ":utf8"); 

# loop throught config
for (my $x=0; $x < scalar(@nsconf); $x++) {
	$warn = 0;
	if($nsconf[$x] =~/(sc|dos|pq)policy/i) {	#Check for deprecated commands
		$warn = 1;
	}
	foreach (@CLASSIC_EXPR) {					#Check for deprecated expressions
		if ($nsconf[$x] =~ /(Policy|policy|rule).+[^-]$_/) { 
			$warn = 1;
		} 
	}
	if ($warn) {								#flag line with '>>>' when needed
	   $warn = ">>>\x{2013}";					
	   $warnings++;
	} else {
	   $warn = "\x{2013}"x 4;					#leave space at begining of line
	}
	$warn .= $nsconf[$x];						#assemble the output line
	print OUTFILE $warn unless (length($warn) eq 4);
}	
print $file_out.' has ', $warnings, " classic configuration commands. \n";
close OUTFILE;
exit;

sub HELP_MESSAGE {
	my $file = __FILE__;
	$file =~ s/.{0,1000}\\//i;
	my $help = '
      version: 8/28/2018 

      Usage: '."$file".' [-h] <in_file> [<out_file>]   

      This program searches a NetScaler configuration file and prefixes
      lines with 3 greater than symbols >>> where configuration commands 
      contain classic policies.  
      Use this output to identify the extent to which convesion to
      advanced policies will be necessary.

      <in_file>      NetScaler input filename.   (ns.conf)
      <out_file>     Output filename.            (*.audit.conf)
      -h             This help screen.
      ';
	print $help;
	exit 1;
}	

__DATA__
CLIENT.CERT 
CLIENT.CERT.ISSUER 
CLIENT.CERT.SERIALNUMBER 
CLIENT.CERT.SIGALGO 
CLIENT.CERT.SUBJECT 
CLIENT.CERT.VERSION 
CLIENT.CIPHER.BITS 
CLIENT.SSL.VERSION 
DATE 
DAYOFWEEK 
DESTIP 
DESTMAC 
DESTPORT 
HEADER 
ID 
LOCATION 
METHOD 
MSS 
REQ.ETHER.DESTMAC 
REQ.ETHER.ID 
REQ.ETHER.RXTHROUGHPUT 
REQ.ETHER.RXTXTHROUGHPUT 
REQ.ETHER.SOURCEMAC 
REQ.ETHER.TXTHROUGHPUT 
REQ.HTTP.HEADER 
REQ.HTTP.METHOD 
REQ.HTTP.URL 
REQ.HTTP.URLLEN 
REQ.HTTP.URLQUERY 
REQ.HTTP.URLQUERYLEN 
REQ.HTTP.URLTOKENS 
REQ.HTTP.VERSION 
REQ.INTERFACE.DESTMAC 
REQ.INTERFACE.ID 
REQ.INTERFACE.RXTHROUGHPUT 
REQ.INTERFACE.RXTXTHROUGHPUT 
REQ.INTERFACE.SOURCEMAC 
REQ.INTERFACE.TXTHROUGHPUT 
REQ.IP.DESTIP 
REQ.IP.SOURCEIP 
REQ.SSL.CLIENT.CERT 
REQ.SSL.CLIENT.CERT.ISSUER 
REQ.SSL.CLIENT.CERT.SERIALNUMBER 
REQ.SSL.CLIENT.CERT.SIGALGO 
REQ.SSL.CLIENT.CERT.SUBJECT 
REQ.SSL.CLIENT.CERT.VALIDFROM 
REQ.SSL.CLIENT.CERT.VALIDTO 
REQ.SSL.CLIENT.CERT.VERSION 
REQ.SSL.CLIENT.CIPHER.BITS 
REQ.SSL.CLIENT.CIPHER.TYPE != Export
REQ.SSL.CLIENT.CIPHER.TYPE == Export
REQ.SSL.CLIENT.SSL.VERSION 
REQ.TCP.DESTPORT 
REQ.TCP.MSS 
REQ.TCP.SOURCEPORT 
REQ.VLANID 
RES.ETHER.DESTMAC 
RES.ETHER.ID 
RES.ETHER.RXTHROUGHPUT 
RES.ETHER.RXTXTHROUGHPUT 
RES.ETHER.SOURCEMAC 
RES.ETHER.TXTHROUGHPUT 
RES.HTTP.HEADER 
RES.HTTP.STATUSCODE 
RES.HTTP.VERSION 
RES.INTERFACE.DESTMAC 
RES.INTERFACE.ID 
RES.INTERFACE.RXTHROUGHPUT 
RES.INTERFACE.RXTXTHROUGHPUT 
RES.INTERFACE.SOURCEMAC 
RES.INTERFACE.TXTHROUGHPUT 
RES.IP.DESTIP 
RES.IP.SOURCEIP 
RES.TCP.DESTPORT 
RES.TCP.MSS 
RES.TCP.SOURCEPORT 
RES.VLANID 
RXTHROUGHPUT 
RXTXTHROUGHPUT 
RXTXTHROUGHPUT 
SOURCEIP 
SOURCEMAC 
SOURCEPORT 
STATUSCODE 
TIME 
URL 
URLLEN 
URLQUERY 
URLQUERYLEN 
URLTOKENS 
VERSION 
VLANID 
ns_cachecontrol_nocache
ns_cachecontrol_nostore
ns_content_type
ns_css
ns_ext_asp
ns_ext_cfm
ns_ext_cgi
ns_ext_ex
ns_ext_exe
ns_ext_htx
ns_ext_not_gif
ns_ext_not_jpeg
ns_ext_shtml
ns_false
ns_header_cookie
ns_header_pragma
ns_mozilla_47
ns_msexcel
ns_msie
ns_msppt
ns_msword
ns_non_get
ns_true
ns_url_path_bin
ns_url_path_cgibin
ns_url_path_exec
ns_url_tokens
ns_xmldata
