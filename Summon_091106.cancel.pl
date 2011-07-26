#!/usr/bin/perl

#The purpose of this script is to create a review
#file of records on a Millennium server that were updated in a certain time period. 
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
#    UCMcan => ['<IP>', '<LoginPswd>', '<Initials>', '<InitPswd>', '76', 'CANCELS_UCM', 'central', ],
#    WJcan => ['<IP>', '<LoginPswd>', '<Initials>', '<InitPswd>', '201', 'CANCELS_WJ', 'jewell', ],
#	MSSUcan => ['<IP>', '<LoginPswd>', '<Initials>', '<InitPswd>', '168', 'CANCELS_MSSU', 'mssu', ],
);


# Main function to get the reports from each system
sub getReport() {
  #take the input parameters and assign to variables for use int the function
($site, $host, $pass, $initials, $ipwd, $list, $sitecode, $catalog) = split (/:/, $data);

$timeout = "1200";
#timeout2 of 5400 seconds is 1 & 1/2 hours
$timeout2 = "5400";
$timeout3 = "1";
$login = "mcoe";
$email = "mcohelp\@mobiusconsortium.org";
#$today = UnixDate("today", "%m%d%y");
$date = UnixDate("today", "%Y-%m-%d");
$hour = UnixDate("today", "%H");
$min = UnixDate("today", "%M");
$sec = UnixDate("today", "%S");

if ($site eq "WJcan" or $site eq "MSSUcan") {
$today = UnixDate("today", "%m%d%y");
	if (UnixDate("today", "%a") eq "Mon") {
		$startdate = UnixDate ("4 days ago", "%m%d%y");
		}
	elsif (UnixDate("today", "%a") eq "Thu") {
        $startdate = UnixDate ("3 days ago", "%m%d%y");
        }
	else {
        exit;
		}
	}

#Quest does not default the year in dates to 20xx so we must use %Y to print the entire year.
elsif ($site eq "UCMcan") {
$today = UnixDate("today", "%m%d%Y");
	if (UnixDate("today", "%a") eq "Mon") {
        $startdate = UnixDate ("4 days ago", "%m%d%Y");
        }
	elsif (UnixDate("today", "%a") eq "Thu") {
        $startdate = UnixDate ("3 days ago", "%m%d%Y");
        }
	else {
        exit;
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

my @patterns1 = ("$list > MCO SUMMON DAILY", "$list > Empty");
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

if ($site eq "WJcan") {
	#Location = wju
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION");
	print $h "wju\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have wjb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "wjb\r";
	$match = $h->expect($timeout,"Choose 1 or 2");
	print $h "1";

	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have wjc
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "wjc\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have wjd
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "wjd\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have wji
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "wji\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have wjj
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "wjj\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have wjo
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "wjo\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have wjp
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "wjp\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have wjr
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "wjr\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have wjs
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "wjs\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have wjx
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "wjx\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have wjy
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "wjy\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#and updated b/t ystrday & today
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "11";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"UPDATED between");
	print $h $startdate;
	$match = $h->expect($timeout,"&");
	print $h $today;
	
	#and bcode3 <> d
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "d";

	#and bcode3 <> n
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "n";
	
	#and bcode3 <> s
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "s";
	
	#and bcode3 <> t
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "t";
	
	#and bcode3 <> m
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

	#updated b/t ystrday & today
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "11";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"UPDATED between");
	print $h $startdate;
	$match = $h->expect($timeout,"&");
	print $h $today;
	
	#and bcode3 = d
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"BCODE3 =");
	print $h "d";

	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";

	#updated b/t ystrday & today
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "11";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"UPDATED between");
	print $h $startdate;
	$match = $h->expect($timeout,"&");
	print $h $today;
	
	#and bcode3 = n
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"BCODE3 =");
	print $h "n";

	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";

	#updated b/t ystrday & today
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "11";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"UPDATED between");
	print $h $startdate;
	$match = $h->expect($timeout,"&");
	print $h $today;
	
	#and bcode3 = s
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"BCODE3 =");
	print $h "s";
	}

elsif ($site eq "UCMcan") {
	#Location = ckw
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION");
	print $h "ckw\r";
	
	#Location all fields do not have ckb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "ckb\r";
	$match = $h->expect($timeout,"Choose 1 or 2");
	print $h "1";

	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have cku
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cku\r";

	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have cky
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
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
	
	#and not suppressed (bcode3 != -, a, or z)
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "-";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "a";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "z";
	}

elsif ($site eq "MSSUcan") {
	#Location = msu
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION");
	print $h "msu\r";
	
	#Location all fields do not have msb
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "msb\r";
	$match = $h->expect($timeout,"Choose 1 or 2");
	print $h "1";
	
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
	
	#and not suppressed (bcode3 != -, l, or z)
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "-";
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
	print $h "z";

	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";

	#updated b/t ystrday & today
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "11";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"UPDATED between");
	print $h $startdate;
	$match = $h->expect($timeout,"&");
	print $h $today;
	
	#and bcode3 = d
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"BCODE3 =");
	print $h "d";

	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";

	#updated b/t ystrday & today
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "11";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"UPDATED between");
	print $h $startdate;
	$match = $h->expect($timeout,"&");
	print $h $today;
	
	#and bcode3 = n
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"BCODE3 =");
	print $h "n";

	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";

	#updated b/t ystrday & today
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "11";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"UPDATED between");
	print $h $startdate;
	$match = $h->expect($timeout,"&");
	print $h $today;
	
	#and bcode3 = s
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"BCODE3 =");
	print $h "s";
	}
	
else {print $h "q";}

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


if ($site eq "UCMcan") {
	$match = $h->expect($timeout,"A > Output MARC records");
	print $h "a";
	$match = $h->expect($timeout,"Choose one (C,B,");
	print $h "c";
	}

elsif ($site eq "WJcan" or $site eq "MSSUcan") {
	$match = $h->expect($timeout,"M > Output MARC records to another system using ");
	print $h "m";
	$match = $h->expect($timeout,"Choose one (C,B,");
	print $h "c";
	}

else {print $h "q";}


#Output file is named w/today's date
if ($site eq "UCMcan") {
	$match = $h->expect($timeout,"Enter name of file");
	print $h "Summon_"."$sitecode"."_"."$today"."\r";
	$match = $h->expect($timeout,"Choose one (R,B,Q)");
	print $h "b";
	}

elsif ($site eq "WJcan" or $site eq "MSSUcan") {
	$match = $h->expect($timeout,"Enter name of file");
	print $h "$catalog"."-catalog-cancels"."-"."$date"."-"."$hour"."-"."$min"."-"."$sec"."\r";
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

$match = $h->expect($timeout,"Choose one (Q)");
print $h "q";
$match = $h->expect($timeout,"Press <SPACE> to continue");
print $h " ";
$match = $h->expect($timeout,"Choose one (Q,R)");
print $h "q";
$match = $h->expect($timeout,"Press <SPACE> to continue");
print $h " ";

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
