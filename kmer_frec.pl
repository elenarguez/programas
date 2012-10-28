#!/usr/bin/perl
#Frecuencias de k-mers en una secuencia.
#Elena Rodriguez

if (@ARGV == 0) {
    print STDERR <<"EOT";
Usage:
$0 lengthKmers inputFile [inputFile2 ...]
EOT
    exit 1;
}


my $nomfich = shift;
my $kmer = int(shift);
my $nomfichOut = $nomfich . ".${kmer}mer"; 

open (my $f,$nomfich) or die "ERROR: $nomfich doesn't open\n"; 
open (my $d,">$nomfichOut") or die "ERROR $nomfichOut doesn't open\n";

chomp (my $sec = <$f>);

if(substr($sec, 0, 1) eq '>'){
	$sec = "";
}

while (<$f>) {
    chomp;
    $sec .= uc $_;

}
close ($f);


my $pKmer = FrecKmer($kmer, \$sec);


print $d "K-mers absolute frequencies > 1 and relative frequencies\n";

my $total = Kmertotal($pKmer);

foreach my $km (sort keys %$pKmer) { # ordenamos el hash

printf $d "%s\t %g\t \t%g\n", $km, $$pKmer{$km}, $$pKmer{$km}/$total  if $$pKmer{$km} >1;

}
close($d);

sub FrecKmer {
    my ($k, $pcadena) = @_;
    my %Kmer;
    my $top = length($$pcadena) - $k+1;
    for (my $i = 0; $i < $top; $i++){
        my $resultado = substr($$pcadena, $i, $k);
	if ($resultado =~/N|X/){
		next;
	}
        $Kmer{$resultado}++;
	
    }
    return \%Kmer;
}

sub Kmertotal{

my ($pKmer) = @_;

	foreach my $km (keys %$pKmer) {
	$total += $$pKmer{$km};

	}
return $total;
}
