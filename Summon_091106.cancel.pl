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
#This script was written by MCO.
#Original Date November 2, 2009
#Last revised March 25, 2010

use Expect;
use Date::Manip;

#List of sites to loop the script through
#NOTE: The "_" is neccessary in the $sitecode part of the lines in credentials b/c when
#             you output the files, the output names cannot have spaces.
my %credentials = (
#    UMCcan => ['<IP>', '<LoginPswd>', '<Initials>', '<InitPswd>', '228', 'CANCELS_UMC', ], 
#    UMKCcan => ['<IP>', '<LoginPswd>', '<Initials>', '<InitPswd>', '227', 'CANCELS_UMKC', ],
#    MSTcan => ['<IP>', '<LoginPswd>', '<Initials>', '<InitPswd>', '226', 'CANCELS_MST', ],
);


# Main function to get the reports from each system
sub getReport() {
  #take the input parameters and assign to variables for use int the function
($site, $host, $pass, $initials, $ipwd, $list, $sitecode) = split (/:/, $data);

$timeout = "1200";
#timeout2 of 5400 seconds is 1 & 1/2 hours
$timeout2 = "5400";
$timeout3 = "1";
$login = "<Login>";


if ($site eq "UMKCcan" or $site eq "UMCcan" or $site eq "MSTcan") {
$today = UnixDate("today", "%m%d%y");
	if (UnixDate("today", "%a") eq "Mon") {
		$startdate = UnixDate ("4 days ago", "%m%d%y");;
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
        $startdate = UnixDate ("4 days ago", "%m%d%Y");;
        }
	elsif (UnixDate("today", "%a") eq "Thu") {
        $startdate = UnixDate ("3 days ago", "%m%d%Y");
        }
	else {
        exit;
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
	$match = $h->expect($timeout3,'-re', 'Choose one \(1-365,F');
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
#thing that is "OR"'ed.  Also, you must list each bib loc to exclude 
#individually and exactly, you cannot use ranges to exclude.

if ($site eq "UMKCcan") {
	#Location = ykb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION");
	print $h "ycb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have kb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "kb\r";
	$match = $h->expect($timeout,"Choose 1 or 2");
	print $h "1";

	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have fkb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "fkb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have fklib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "fklib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have fwkb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "fwkb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have kbb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "kbb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have kdb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "kdb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have khb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "khb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have kliib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "kliib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have knb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "knb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have kngb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "kngb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have krb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "krb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have eb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "eb\r";

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
	
	#and bcode3 <> n
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "n";
	
	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";

	#Location = k0b
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION");
	print $h "k0b\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have kb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "kb\r";

	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have fkb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "fkb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have fklib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "fklib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have fwkb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "fwkb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have kbb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "kbb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have kdb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "kdb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have khb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "khb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have kliib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "kliib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have knb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "knb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have kngb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "kngb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have krb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "krb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have eb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "eb\r";
	
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
	
	#and bcode3 <> n
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
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
	
	#and bcode3 = n
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"BCODE3 =");
	print $h "n";
	}

elsif ($site eq "UMCcan") {
	#Location = ycb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION");
	print $h "ycb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have caiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "caiib";
	$match = $h->expect($timeout,"Choose 1 or 2");
	print $h "1";

	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have cdiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cdiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have ceiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "ceiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cgiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cgiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have chhib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "chhib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have chiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "chiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cjiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cjiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cliib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cliib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cmiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cmiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cniib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cniib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cpiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cpiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have csiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "csiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have ctiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "ctiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cviib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cviib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cyiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cyiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have eb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "eb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have fciib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "fciib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have fclb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "fclb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have fwcb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "fwcb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have ucaib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "ucaib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have ucwib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "ucwib";
	
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
	
	#and bcode3 <> n
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
	print $h "n";
	
	#OR
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "o";

	#Location = c0iib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION");
	print $h "c0iib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have caiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "caiib";

	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have cdiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cdiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have ceiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "ceiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cgiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cgiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have chhib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "chhib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have chiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "chiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cjiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cjiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cliib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cliib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cmiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cmiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cniib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cniib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cpiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cpiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have csiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "csiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have ctiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "ctiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cviib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cviib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have cyiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "cyiib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have eb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "eb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have fciib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "fciib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have fclb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "fclb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have fwcb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "fwcb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have ucaib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "ucaib";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have ucwib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "ucwib";
	
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
	
	#and bcode3 <> n
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
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
	
	#and bcode3 = n
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"BCODE3 =");
	print $h "n";
	}

elsif ($site eq "MSTcan") {
	#Location = yrb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"LOCATION");
	print $h "yrb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have rwiib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "rwiib";
	$match = $h->expect($timeout,"Choose 1 or 2");
	print $h "1";

	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";

	#Location all fields do not have eb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "eb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have farb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "farb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have frwb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "frwb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have fwrb
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "fwrb\r";
	
	#AND
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";
	
	#Location all fields do not have urwib
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "03";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "x";
	$match = $h->expect($timeout,"LOCATION does not have");
	print $h "urwib";
	
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
	
	#and bcode3 <> n
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "~";
	$match = $h->expect($timeout,"BCODE3 <>");
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
	
	#and bcode3 = n
	$match = $h->expect($timeout,"Enter action ( A");
	print $h "a";	
	$match = $h->expect($timeout,"Enter code in front of desired field");
	print $h "07";
	$match = $h->expect($timeout,"Enter boolean condition");
	print $h "=";
	$match = $h->expect($timeout,"BCODE3 =");
	print $h "n";
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


if ($site eq "UCMcan") {
	$match = $h->expect($timeout,"A > Output MARC records");
	print $h "a";
	$match = $h->expect($timeout,"Choose one (C,B,");
	print $h "c";
	}

elsif ($site eq "UMKCcan" or $site eq "UMCcan" or $site eq "MSTcan") {
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
