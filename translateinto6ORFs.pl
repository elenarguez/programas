#!/usr/bin/perl
#Traducir una proteina en los 6 marcos de lectura posibles.
#Elena Rodriguez

use warnings;
use strict;
use Switch;


if (@ARGV < 2) {
    print STDERR <<"EOT";
Usage:
$0  inputFile Frame [1,2,3,F,-1,-2,-3,R or 6]
EOT
    exit 1;
}

my $nomfich = shift;
my $frame = shift;
my $nomfichOut = $nomfich.".Frame ${frame}";


open( my $f, $nomfich ) or die "ERROR: $nomfich doesn't open\n";
open (my $d,">$nomfichOut") or die "ERROR $nomfichOut doesn't open\n";

chomp (my $sec = <$f>);

if(substr($sec,0,1) eq '>'){
	$sec = "";
}

while (<$f>) {
    chomp;
    $sec .= $_;

}
close ($f);

$sec =~ tr/acgtuACGTU//cd;
my $revcom = revcom($sec);

switch ($frame){
	case [1..3] { print $d traducir(marco($sec,$frame))."\n"}
	case "F" { foreach my $i (1..3){ 
			print $d "Frame $i\n".traducir(marco($sec,$i))."\n\n";}
		 }
	case [-3..-1] {print $d traducir(marco($revcom,-$frame))."\n"}
	case "R" {foreach my $i (1..3){ 
			print $d "Frame -$i\n".traducir(marco($revcom,$i))."\n\n";}
		 }
	case 6 {foreach my $i (1..3){ 
			print $d "Frame $i\n".traducir(marco($sec,$i))."\n\n";}
		foreach my $i (1..3){ 
			print $d "Frame -$i\n".traducir(marco($revcom,$i))."\n\n";}
		}
}	

close ($d);

###################### SUBRUTINAS ####################

#Subrrutina para traducir cada codon en proteina


sub traducir{
	my($sec)= @_;
	my $proteina= "";
	my(%codigo)=('TCA'=>'S','TCC'=>'S','TCG'=>'S','TCT'=>'S','UCU'=>'S','UCC'=>'S','UCA'=>'S','UCG'=>'S','TTC'=>'F','TTT'=>'F','UUU'=>'F','UUC'=>'F','TTA'=>'L','TTG'=>'L','CTT'=>'L','CTC'=>'L','CTA'=>'L','CTG'=>'L','CUU'=>'L','CUC'=>'L','CUA'=>'L','CUG'=>'L','TAC'=>'Y','TAT'=>'Y','UAU'=>'Y','UAC'=>'Y','TAA'=>'_','TAG'=>'_','UAA'=>'_','UAG'=>'_','TGC'=>'C','TGT'=>'C','UGU'=>'C','UGC'=>'C','TGA'=>'_','UGA'=>'_','TGG'=>'W','UGG'=>'W','CTA'=>'L','CTC'=>'L','CTG'=>'L','CTT'=>'L','TTA'=>'L','TTG'=>'L','CUU'=>'L','CUC'=>'L','CUA'=>'L','CUG'=>'L','CCA'=>'P','CCC'=>'P','CCG'=>'P','CCT'=>'P','CCU'=>'P','CAC'=>'H','CAT'=>'H','CAU'=>'H','CAA'=>'Q','CAG'=>'Q','CGA'=>'R','CGC'=>'R','CGG'=>'R','CGT'=>'R','ATA'=>'I','ATC'=>'I','ATT'=>'I','AUU'=>'I','AUC'=>'I','AUA'=>'I','ATG'=>'M','AUG'=>'M','ACA'=>'T','ACC'=>'T','ACG'=>'T','ACT'=>'T','ACU'=>'T','AAC'=>'N','AAT'=>'N','AAU'=>'N','AAA'=>'K','AAG'=>'K','AGC'=>'S','AGT'=>'S','AGU'=>'s','AGA'=>'R','AGG'=>'R','GTA'=>'V','GTC'=>'V','GTG'=>'V','GTT'=>'V','GUU'=>'V','GUC'=>'V','GUA'=>'V','GUG'=>'V','GCA'=>'A','GCC'=>'A','GCG'=>'A','GCT'=>'A','GCU'=>'A','GAC'=>'D','GAT'=>'D','GAU'=>'D','GAA'=>'E','GAG'=>'E','GGA'=>'G','GGC'=>'G','GGG'=>'G','GGT'=>'G','GGU'=>'G');



	for (my $i = 0; $i < (length($sec)-2); $i+=3){
		my $codon = substr($sec,$i,3);
		$codon= uc $codon;

		my $aa = $codigo{$codon};
		$proteina .= $aa;
		
	}
		return($proteina);
}


#Subrrutina para determinar los marcos de lectura

sub marco {
	my($sec,$pos)= @_;
	my $secuencia = substr($sec,$pos-1);# La primera posición es la 0.
	return($secuencia);
}

#Subrrutina para determinar la reversacomplementaria

sub revcom {
	my ($sec)= @_;
	my $revcom= reverse($sec); 
	$revcom =~ tr/ACGTUacgtu/TGCAAtgcaa/;
	return($revcom);
}



