#!/usr/bin/perl

#The purpose of this script is to create a review
#file of records in the III character based interface.
#The records are added to the review file based on the
#the update date and location codes of the bibliographic
#record.  It uses Expect as part of perl.
#
#The scripts logs onto the server and creates the list of
#records.  It then creates a file of those records that is
#manually ftp'ed off of the system and sent to the vendor.
#This script was written by the MOBIUS Consortium Office.
#Original Date November 2, 2009
#Last revised March 25, 2010


use Expect;
use Date::Manip;

#List of sites to loop the script through
#NOTE: The "_" is neccessary in the $sitecode part of the lines in credentials b/c when
#             you output the files, the output names cannot have spaces.
my %credentials = (
#    UMCadd => ['<IP>', '<LoginPswd>', '<Initials>', '<InitPswd>', '154', 'ADDS_UMC', ],
#    UMKCadd => ['<IP>', '<LoginPswd>', '<Initials>', '<InitPswd>', '182', 'ADDS_UMKC', ],
#    MSTadd => ['<IP>', '<LoginPswd>', '<Initials>', '<InitPswd>', '156', 'ADDS_MST', ],
#    UCMadd => ['<IP>', '<LoginPswd>', '<Initials>', '<InitPswd>', '136', 'ADDS_UCM', ],
);



# Main function to get the reports from each system
sub getReport() {
  #take the input parameters and assign to variables for use in the function
($site, $host, $pass, $initials, $ipwd, $list, $sitecode) = split (/:/, $data);

$timeout = "1200";
#timeout2 of 5400 seconds is 1 & 1/2 hours
$timeout2 = "5400";
$timeout3 = "1";
$login = "<Login>";


if ($site eq "UMKCadd" or $site eq "UMCadd" or $site eq "MSTadd") {
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
	
	

#Opens a ssh session, logs in, and goes to create list
my $h = Expect->spawn("ssh $login\@$host");
$match = $h->expect($timeout,"password:");
print $h "$pass\r";


$match = $h->expect($timeout,"MANAGEMENT information");
print $h "m";
$match = $h->expect($timeout,"Create LISTS of records");
print $h "l";
$match = $h->expect($timeout,"Please key your initials");
print $h "$initials\r";
$match = $h->expect($timeout,"Please key your password");
print $h "$ipwd\r";

#Looks for the review file number listed in my creditials
#going forward through screens until it finds it.
#Once it finds the file, it verifies the name of the file
#and then prints the list number to open that list.
#If it doesn't find the file named correctly where expected, 
#then it times out eventually.

until ($match = $h->expect($timeout3,"$list > MCO SUMMON DAILY "."$sitecode")) {
	$match = $h->expect($timeout3,'-re', 'Choose one \(1-');
	print $h "f";
	}

print $h "$list";

#Clears the file and chooses to create a new bib file
$match = $h->expect($timeout,"MCO SUMMON DAILY "."$sitecode");
print $h "n";

$match = $h->expect($timeout,"current review file? (y/n)");
print $h "y";

$match = $h->expect($timeout,"B > BIBLIOGRAPHIC list");
print $h "b";

#Criteria for the search.  Character based does not allow grouping and
#"breaks" at "OR"'s, so anything that is "AND"'ed must be done to each
#thing that is "OR"'ed.

if ($site eq "UMKCadd") {
	#Location b/t k & kzzzz
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"LOCATION between");
	print $h "k\r";
	$match = $h->expect($timeout,"&");
	print $h "kzzzz";
	
	#and location not equal to kngb
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"LOCATION");
	print $h "kngb\r";
	
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
	
	#and not suppressed (bcode3 != c, d, f, n, & w)
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
	print $h "f";
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
	print $h "w";

	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";
	
	#Location = fkb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION");
	print $h "fkb\r";
	
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
	
	#and not suppressed (bcode3 != c, d, f, n, & w)
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
	print $h "f";
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
	print $h "w";

	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";
	
	#Location = fklib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION");
	print $h "fklib";

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
	
	#and not suppressed (bcode3 != c, d, f, n, & w)
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
	print $h "f";
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
	print $h "w";

	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";

	#Location b/t eb & ebzzz
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"LOCATION between");
	print $h "eb\r";
	$match = $h->expect($timeout,"&");
	print $h "ebzzz";

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
	
	#and not suppressed (bcode3 != c, d, f, n, & w)
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
	print $h "f";
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
	print $h "w";
	}
	
elsif ($site eq "UMCadd") {
	#Location b/t ca & cazzz
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"LOCATION between");
	print $h "ca\r";
	$match = $h->expect($timeout,"&");
	print $h "cazzz";
	
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
	
	#and not suppressed (bcode3 != c, d, n, w, & z)
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
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "w";
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
	
	#Location b/t fc & fczzz
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"LOCATION between");
	print $h "fc\r";
	$match = $h->expect($timeout,"&");
	print $h "fczzz";
	
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
	
	#and not suppressed (bcode3 != c, d, n, w, & z)
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
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "w";
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

	#Location b/t fwc & fwczz
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"LOCATION between");
	print $h "fwc\r";
	$match = $h->expect($timeout,"&");
	print $h "fwczz";
	
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
	
	#and not suppressed (bcode3 != c, d, n, w, & z)
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
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "w";
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
	
	#Location b/t ua & uzzzz
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"LOCATION between");
	print $h "ua\r";
	$match = $h->expect($timeout,"&");
	print $h "uzzzz";
	
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
	
	#and not suppressed (bcode3 != c, d, n, w, & z)
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
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "w";
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
	
	#Location b/t ea & ezzzz
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"LOCATION between");
	print $h "ea\r";
	$match = $h->expect($timeout,"&");
	print $h "ezzzz";
	
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
	
	#and not suppressed (bcode3 != c, d, n, w, & z)
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
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "w";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "z";
	}

elsif ($site eq "MSTadd") {
	#Location b/t r & rzzzz
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"LOCATION between");
	print $h "r\r";
	$match = $h->expect($timeout,"&");
	print $h "rzzzz";
	
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
	
	#and not suppressed (bcode3 != c, n, & w)
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
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "w";


	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";
	
	#Location = farb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION");
	print $h "farb\r";
	
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
	
	#and not suppressed (bcode3 != c, n, & w)
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
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "w";


	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";
	
	#Location = fwrb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION");
	print $h "fwrb\r";

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
	
	#and not suppressed (bcode3 != c, n, & w)
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
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "w";

	
	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";

	#Location b/t e & ezzzz
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"LOCATION between");
	print $h "e\r";
	$match = $h->expect($timeout,"&");
	print $h "ezzzz";

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
	
	#and not suppressed (bcode3 != c, n, & w)
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
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "w";


	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";

	#Location b/t frw & frwzz
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "w";
	$match = $h->expect($timeout,"LOCATION between");
	print $h "frw\r";
	$match = $h->expect($timeout,"&");
	print $h "frwzz";

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
	
	#and not suppressed (bcode3 != c, n, & w)
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
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "w";
	

	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";
	
	#Location = uraib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION");
	print $h "uraib";

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
	
	#and not suppressed (bcode3 != c, n, & w)
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
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "w";
	

	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";
	
	#Location = urwib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION");
	print $h "urwib";

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
	
	#and not suppressed (bcode3 != c, n, & w)
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
	print $h "n";
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "w";
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
#into Read/Write MARC records to create the out file of bib & attached records.
$match = $h->expect($timeout,"Choose one (T,P");
print $h "q";
$match = $h->expect($timeout,"Q > QUIT");
print $h "q";
$match = $h->expect($timeout,"Q > QUIT");
print $h "q";

$match = $h->expect($timeout,"Choose one (S,D,C,M,B,A,X)");
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

elsif ($site eq "UMKCadd" or $site eq "UMCadd" or $site eq "MSTadd") {
	$match = $h->expect($timeout,"G > Output MARC records to another system using IFTS");
	print $h "g";
	$match = $h->expect($timeout,"Choose one (C,B,");
	print $h "c";
	}

else {print $h "q";}
	
#Output file is named w/today's date
$match = $h->expect($timeout,"Enter name of file");
print $h "Summon_"."$sitecode"."_"."$today"."\r";
$match = $h->expect($timeout,"Choose one (R,B,Q)");
print $h "b";


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
