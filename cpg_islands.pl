#!/usr/bin/perl
#Islas CpG
#La búsqueda se realiza de acuerdo a los criterios de Takai D,  Jones PA.  (2002): (i) contenido GC por encima del 55%, (ii) la proporción del número observado frente al esperado de dinucleótidos CpG por encima de 0,65, (iii) más de 500 pares de bases de longitud.
#Elena Rodríguez


use warnings;
use strict;

use constant true  => 1;
use constant false => 0;
use constant WINSIZE => 500;
use constant PORC_MIN => 55;
use constant RATIO_MIN => 0.65;
use constant CG => "CG";



if (@ARGV == 0) {
    print STDERR <<"EOT";
Usage:
$0 inputFile [Gap between adjacent islands]
EOT
    exit 1;
}


my $brecha = 0;
if ($#ARGV == 1 ) {

	$brecha = $ARGV[1];
}

my $nomfich = shift;
my $nomfichOut = $nomfich . ".CpG_Islands"; 

open( my $f, $nomfich ) or die "ERROR: $nomfich doesn't open\n";
open (my $d,">$nomfichOut") or die "ERROR $nomfichOut doesn't open\n";

chomp (my $sec = <$f>);

if (substr($sec,0,1) eq '>'){
    $sec = "";
}

while (<$f>) {
    chomp;
    $sec .= uc $_;
}

close ($f);


sub main() {

brecha(buscaislas($sec));

}

main();


################### SUBRUTINAS ######################

sub buscaislas {

my $sec = $_[0];

my $w_ini = index($sec, CG);
my $w_ancho = WINSIZE;
my $isla_fin;
my $sec_length = length($sec);
my $contCG;
my $ratio;
my $i = 0;
my @islas = 0;


# Recorremos la secuencia con una ventanas de 500 bp calculando el número de Cs,Gs y dimeros CG dentro de la ventana.

my $era_isla = 0;

while ( $w_ini + $w_ancho < $sec_length ) {

    my $es_isla = secumple($w_ini, $w_ancho, \$contCG, \$ratio);

    if ($es_isla) {

        ++$w_ancho;

        $era_isla = true;

    } elsif ($era_isla) {

        $isla_fin = $w_ini + $w_ancho;


	# Guardamos todos los parametros de las islas.
	
	$islas[$i] = ({ini => $w_ini, fin => $isla_fin, pCG => $contCG, ratio => $ratio});
	$i++;


        # Cuando no cumpla nos posicionamos en la posición siguiente donde ya no se cumplian las condiciones,buscamos el primer CG y reseteamos la ventana a WINSIZE

        $w_ancho = WINSIZE;

        $w_ini = index($sec, CG, $isla_fin + 1);


	# Control de llegada a fin de secuencia sin encontrar CG

	if ($w_ini == -1 && $isla_fin > 0) { 
		$w_ini = length($sec)-1; 
	}

        $era_isla = false;

    } else {
	
         $w_ini = index($sec, CG, $w_ini + 1);

    }

  }

return @islas;
}



# Criterios a cumplir para ser una isla CpG

sub secumple {
    my ($w_ini, $w_ancho, $pcontCG, $pratio) = @_;
    my $win = substr($sec, $w_ini, $w_ancho);
    my $c =($win =~ tr/cC//);
    my $g =($win =~ tr/gG//);
    my $cg = 0;
    while ($win =~ /CG/ig) {++$cg}
    my $contCG =($c + $g)/$w_ancho * 100;

    my $ratio = 0;
    if ($c != 0 and $g != 0) {
        $ratio = ($cg * $w_ancho) / ($c * $g);
    }
    if ($contCG >= PORC_MIN and $ratio >= RATIO_MIN) {
        $$pcontCG = $contCG;
        $$pratio  = $ratio;
        return 1;
    } else {
        return 0;
    }   
}


# Unir islas contiguas separadas por una distancia dada.

sub brecha {

my @islas = @_;

my $contCG;
my $ratio;


if ($#islas > 0) {

	printf $d "Start \t End \t GC content \t Ratio \t\tLength\n";

	if ($brecha == 0){

		foreach my $isla (@islas) {
	    
		   mostrarResultado($isla);
		 }
		 
	}else{

		for(my $i = 0; $i <= $#islas; $i++){
		
			if($islas[$i+1]){ 

				my $j = 0;
			
				# Buscamos cuantas islas contiguas están a menor distancia que la brecha para unirlas.
			
				while (($i + $j + 1 <= $#islas) && ($islas[$i + $j + 1]->{ini} - $islas[$i + $j]->{fin} <= $brecha)){
					$j++;	
				}
			
				if ($j > 0){ 

					my $w_ini = $islas[$i]->{ini};
					my $isla_fin = $islas[$i + $j]->{fin};
					my $long = $isla_fin - $w_ini;

					my $es_isla = secumple($w_ini, $long, \$contCG, \$ratio);

					if ($es_isla) {

						$i = $i + $j; #Saltamos la posición de la siguiente isla ya que la hemos combinado.
					
						mostrarResultado({ini => $w_ini, fin => $isla_fin, pCG => $contCG, ratio => $ratio}); 
						
					}else{
				
						while ($long > ($islas[$i]->{fin} - $islas[$i]->{ini})){
						
								$long--; 
					
								my $es_isla = secumple($w_ini, $long, \$contCG, \$ratio);

							if ($es_isla){
					
								$i = $i + $j; 

								mostrarResultado({ini => $w_ini, fin => $w_ini + $long, pCG => $contCG, ratio => $ratio});

								$long = 0; #Forzar salida del bucle.

							}
							
						}# Si recortando no llega a cumplir las condiciones mostramos las islas por separado.

						if ($long == ($islas[$i]->{fin} - $islas[$i]->{ini})){

						mostrarResultado($islas[$i]);
						}
				       }
	
			  	}else{
			
				mostrarResultado($islas[$i]);

				}

		    	}else{

			mostrarResultado($islas[$i]);

			}
		}
	}	
}else{
	print $d "No CpG islands found\n";
}
}


sub mostrarResultado {

	my $isla = $_[0];
	
	printf $d "%d\t%d\t%g\t\t%g\t%g\n", $isla->{ini}, $isla->{fin}, $isla->{pCG}, $isla->{ratio}, ($isla->{fin} - $isla->{ini});
}
close ($d);
