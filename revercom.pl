#!/usr/bin/perl
#Obtener la secuencia reversa complementaria
#Elena Rodriguez

use warnings;
use strict;

if (@ARGV == 0) {
    print STDERR <<"EOT";
Usage:
$0 inputFile outputFile
EOT
    exit 1;
}


my $nomfich = shift;
my $nomfichOut = $nomfich.".revercom";


open (my $f,$nomfich) or die "ERROR: $nomfich doesn't open\n";
open (my $d,">$nomfichOut") or die "ERROR $nomfichOut doesn't open\n";

chomp ( my $sec = <$f>);

if(substr($sec,0,1) eq '>'){
	$sec = "";
}

while (<$f>) {
    chomp;
    $sec .= $_;
 
}
close($f);

$sec =~ tr/acgtuACGTU//cd;
$sec =~ tr/ACGTUacgtu/TGCAAtgcaa/; 

my $complementaria = reverse($sec);
print $d $complementaria; 

close($d);
