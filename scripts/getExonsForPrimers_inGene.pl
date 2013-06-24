#!/usr/bin/perl
use warnings;
use strict;
use Bio::DB::SeqFeature::Store;
use Data::Dumper;

my $sqlite = shift;
my $gene_file = shift;
die "Please provide a SQLite datafile of a seqfeature db" if !defined $sqlite;

#############################################################################
## make a Bio::DB::SeqFeature::Store object (contains info about  organism in
## SQLite database and all the methods needed to interact with the database
#############################################################################

#Open the sequence database
my $db_obj = Bio::DB::SeqFeature::Store->new(
  -adaptor => 'DBI::SQLite',
  -dsn     => $sqlite
);

my @features;
open IN, $gene_file , or die "Can't open $gene_file\n";
while (my $gene = <IN>){
  chomp $gene;
  push @features , $db_obj->get_features_by_name($gene);
}
open OUTEXONS, ">exons_for_primers.txt" or die "Can't open transcript_exons_info.txt";
foreach my $feature ( @features ) {
  my $f_name  = $feature->name;
  my $f_start = $feature->start;
  my $f_end   = $feature->end;
  my $ref     = $feature->ref;
  my $strand = $feature->strand;
  $strand = $strand > 0 ? '+' : '-';
  my @features_exons = $db_obj->features(
            -type => 'exon',
            -seq_id => $ref,
            -start  => $f_start,
            -end    => $f_end
        );
  my @exons;
  my @overlaps;
  foreach my $f (sort {$a->start <=> $b->start} @features_exons) {
    my %attr = $f->attributes;
    my $parent_id = ${$attr{parent_id}}[0];
    next unless $parent_id eq $f_name; 
    my $e_start = $f->start;
    my $e_end   = $f->end;
    ## get seq of exon
    my $e_seq =$db_obj->fetch_sequence(-seq_id=>$ref,-start=>$e_start,-end=>$e_end);
    push @exons , $e_seq;
    #push @overlaps , $overlaps[-1] + (length $e_seq);
  }
  print "$f_name has only one exon\n" if @exons == 0;
  my $seq = join ('-',@exons);
  #print OUTEXONS "$f_name\t$ref\t$start,$end\t".join(';',@exons)."\n";
  print ">$f_name\n$seq\n";


}
__END__
## add write of primer3 input file
my $overlaps = join (" ",@overlaps);
  #print P3IN "
  print  "
SEQUENCE_ID=$f_name
SEQUENCE=$seq
SEQUENCE_OVERLAP_JUNCTION=$overlaps
PRIMER_OPT_SIZE=22
PRIMER_MIN_SIZE=18
PRIMER_MAX_SIZE=25
PRIMER_OPT_TM=60
PRIMER_MAX_TM=63
PRIMER_MIN_TM=57
PRIMER_OPT_GC=50
PRIMER_MAX_GC=80
PRIMER_MIN_GC=40
PRIMER_GC_CLAMP=1
=\n";
}

#`primer3_core < $cwd/primers/$fasta.primer3in > $cwd/primers/$fasta.primer3out`;

                                                                           
