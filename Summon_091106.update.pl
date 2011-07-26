#!/usr/bin/perl

#The purpose of this script is to create a review
#file of records on a Millennium server that were updated yesterday. 
#It uses the Expect module to log in to the server and create
#the list.  It then creates a file to be exported off of the system.
#This script was written by Janine Gordon 
#MOBIUS Consortium Office
#Creation Date: November 2, 2009
#Last Revision: July 19, 2011

use Expect;
use Date::Manip;

#List of sites to loop the script through
#NOTE: The "_" is neccessary in the $sitecode part of the lines in credentials b/c when
#             you output the files, the output names cannot have spaces.
my %credentials = (
#    UCMadd => ['<IP>', '<LoginPswd>', '<Initials>', '<InitPswd>', '136', 'ADDS_UCM', 'central', ],
#    WJadd => ['<IP>', '<LoginPswd>', '<Initials>', '<InitPswd>', '200', 'ADDS_WJ', 'jewell', ],
#	MSSUadd => ['<IP>', '<LoginPswd>', '<Initials>', '<InitPswd>', '167', 'ADDS_MSSU', 'mssu', ],
);



# Main function to get the reports from each system
sub getReport() {
  #take the input parameters and assign to variables for use int the function
($site, $host, $pass, $initials, $ipwd, $list, $sitecode, $catalog) = split (/:/, $data);

$timeout = "1200";
#timeout2 of 7200 seconds is 1 & 1/2 hours
$timeout2 = "7200";
$timeout3 = "1";
$login = "mcoe";
$email = "mcohelp\@mobiusconsortium.org";
#$today = UnixDate("today", "%m%d%y");
$date = UnixDate("today", "%Y-%m-%d");
$hour = UnixDate("today", "%H");
$min = UnixDate("today", "%M");
$sec = UnixDate("today", "%S");

if ($site eq "WJadd" or $site eq "MSSUadd") {
$today = UnixDate("today", "%m%d%y");
	if (UnixDate("today", "%a") eq "Sun") {
		exit;
		}
	elsif (UnixDate("today", "%a") eq "Sat") {
		exit;
		}	
	elsif (UnixDate("today", "%a") eq "Mon") {
		$startdate = UnixDate ("3 days ago", "%m%d%y");
		}
	else {
		$startdate = UnixDate("yesterday", "%m%d%y");
		}
	}

#Quest does not default the year in dates to 20xx so we must use %Y to print the entire year.
elsif ($site eq "UCMadd") {
$today = UnixDate("today", "%m%d%Y");
	if (UnixDate("today", "%a") eq "Sun") {
		exit;
		}
	elsif (UnixDate("today", "%a") eq "Sat") {
		exit;
		}	
	elsif (UnixDate("today", "%a") eq "Mon") {
		$startdate = UnixDate ("3 days ago", "%m%d%Y");
		}
	else {
		$startdate = UnixDate("yesterday", "%m%d%Y");
		}
	}
	
else {print $h "q";}
	
	
#Opens a telnet session, logs in, and goes to create list
my $h = Expect->spawn("telnet $host");
my $match = $h->expect($timeout,"login: ");
print $h "$login\r";
$match = $h->expect($timeout,"Password:");
print $h "$pass\r";

$match = $h->expect($timeout,"MANAGEMENT information");
print $h "m";
$match = $h->expect($timeout,"Create LISTS of records");
print $h "l";
$match = $h->expect($timeout,"Please key your initials");
print $h "$initials\r";
$match = $h->expect($timeout,"Please key your password");
print $h "$ipwd\r";

#Looks for the review file, until it finds it, the system will go forward.  
#Once it finds the file, it will print the list number to open that list.
#If it doesn't find the file named correctly where expected, then it exits.

my @patterns1 = ("$list > MCO SUMMON DAILY", "Empty");
until ($match = $h->expect($timeout3, @patterns1)) {
	$match = $h->expect($timeout3,'-re', 'Choose one \(1-');
	print $h "f";
	}

print $h "$list";

#Clears the file and chooses bib list for new file
my @patterns2 = ("MCO SUMMON DAILY", "Choose one (1,2,Q)");
$match = $h->expect($timeout, @patterns2);
	if ($match ==1) {
		print $h "n";
	
		$match = $h->expect($timeout,"current review file? (y/n)");
		print $h "y";
		}
	
	elsif ($match == 2) {
		print $h "2";
		}

$match = $h->expect($timeout,"B > BIBLIOGRAPHIC list");
print $h "b";


if ($site eq "WJadd") {
	#Location b/t wjb & wjt
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"LOCATION between");
	print $h "wjb\r";
	$match = $h->expect($timeout,"&");
	print $h "wjt\r";
	
	#and updated b/t ystrday & today
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "11";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"UPDATED between");
	print $h $startdate;
	$match = $h->expect($timeout,"&");
	print $h $today;
	
	#and not suppressed (bcode3 != c, d, l, n, s, t, m)
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "c";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "d";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "l";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "s";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "t";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "m";


	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";
	
	#Location b/t wjx & wjy
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"LOCATION between");
	print $h "wjx\r";
	$match = $h->expect($timeout,"&");
	print $h "wjy\r";

	#and updated b/t ystrday & today
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "11";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"UPDATED between");
	print $h $startdate;
	$match = $h->expect($timeout,"&");
	print $h $today;
	
	#and not suppressed (bcode3 != c, d, l, n, s, t, m)
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "c";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "d";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "l";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "s";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "t";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "m";
	}

elsif ($site eq "UCMadd") {
	#Location b/t cka & ckv
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"LOCATION between");
	print $h "ckb\r";
	$match = $h->expect($timeout,"& ");
	print $h "ckv\r";
	
	#and updated b/t ystrday & today
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "11";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"UPDATED between");
	print $h $startdate;
	$match = $h->expect($timeout,"&");
	print $h $today;
	
	#and not suppressed (bcode3 != c, d, l, m, n, s, t)
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "c";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "d";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "l";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "s";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "t";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "m";


	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";

	#Location =cky
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION =");
	print $h "cky\r";
	
	#and updated b/t ystrday & today
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "11";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"UPDATED between");
	print $h $startdate;
	$match = $h->expect($timeout,"&");
	print $h $today;
	
	#and not suppressed (bcode3 != c, d, l, m, n, s, t)
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "c";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "d";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "l";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "s";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "t";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "m";
	}

elsif ($site eq "MSSUadd") {
	#Location eq msb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION =");
	print $h "msb\r";
	
	#and updated b/t ystrday & today
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "11";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"UPDATED between");
	print $h $startdate;
	$match = $h->expect($timeout,"&");
	print $h $today;
	
	#and not suppressed (bcode3 != n, s, d)
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "s";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "d";
	}

else {print $h <Esc>;
	$match = $h->expect($timeout,"Choose one (");
	print $h "q";
	$match = $h->expect($timeout,"Choose one (");
	print $h "q";
	$match = $h->expect($timeout,"Choose one (");
	print $h "q";
	$match = $h->expect($timeout,"Choose one (");
	print $h "x";
	exit
	}

#Starts the search and names the file
$match = $h->expect($timeout,"Enter action ( A");
print $h "s";
$match = $h->expect($timeout,"What name would you like to give this");
print $h "MCO SUMMON DAILY "."$sitecode"." "."$today"."\r";
$match = $h->expect($timeout2,"Press <SPACE> to continue");
print $h " ";

#When the file is complete, the script quits to the main menu and goes
#into Read/Write MARC records to out the bib & attached records.
$match = $h->expect($timeout,"Choose one (T,P");
print $h "q";
$match = $h->expect($timeout,"Q > QUIT");
print $h "q";
$match = $h->expect($timeout,"Q > QUIT");
print $h "q";

$match = $h->expect($timeout,"Choose one (S,D,C,");
print $h "a";
$match = $h->expect($timeout,"M > Read/write MARC records");
print $h "m";
$match = $h->expect($timeout,"Please key your initials");
print $h "$initials\r";
$match = $h->expect($timeout,"Please key your password");
print $h "$ipwd\r";

if ($site eq "UCMadd") {
	$match = $h->expect($timeout,"A > Output MARC records");
	print $h "a";
	$match = $h->expect($timeout,"Choose one (C,B,");
	print $h "c";
	}

elsif ($site eq "WJadd" or $site eq "MSSUadd") {
	$match = $h->expect($timeout,"M > Output MARC records to another system using ");
	print $h "m";
	$match = $h->expect($timeout,"Choose one (C,B,");
	print $h "c";
	}
	
else {print $h "q";}
	
#Output file is named w/today's date
if ($site eq "UCMadd") {
	$match = $h->expect($timeout,"Enter name of file");
	print $h "Summon_"."$sitecode"."_"."$today"."\r";
	$match = $h->expect($timeout,"Choose one (R,B,Q)");
	print $h "b";
	}

elsif ($site eq "WJadd" or $site eq "MSSUadd") {
	$match = $h->expect($timeout,"Enter name of file");
	print $h "$catalog"."-catalog-updates"."-"."$date"."-"."$hour"."-"."$min"."-"."$sec"."\r";
	$match = $h->expect($timeout,"Choose one (R,B,Q)");
	print $h "b";
	}
	
#The script searches until it find the list created and then prints the list number
until ($match = $h->expect($timeout3,'-re','(\d{3}) > MCO SUMMON DAILY '."$sitecode")) {
	$match = $h->expect($timeout3,"F > FORWARD");
	print $h "f";
	}

my $code = ($h->matchlist)[0];
print $h "$code";

$match = $h->expect($timeout,"Choose one (I,S,N,Q)");
print $h "s";

$match = $h->expect($timeout,"Choose one (");
print $h "q";
$match = $h->expect($timeout,"Press <SPACE> to continue");
print $h " ";
$match = $h->expect($timeout,"Choose one (Q,R)");
print $h "q";
$match = $h->expect($timeout,"Press <SPACE> to continue");
print $h " ";
$match = $h->expect($timeout,"Choose one (");
print $h "q";

#Exit the INNOPAC system
$match = $h->expect($timeout3,"Q > QUIT");
print $h "q";
$match = $h->expect($timeout3,"Q > QUIT");
print $h "q";
print $h "q";

$match = $h->expect($timeout3,"X > DISCONNECT");
print $h "x";
}

for $site ( sort keys %credentials ) {
        $data = "$site:";
        for $i ( 0 .. $#{ $credentials{$site} } ) {
        #        print " $i = $credentials{$site}[$i]";
        $data .= $credentials{$site}[$i] . ":";
        }
        &getReport($data);
}
