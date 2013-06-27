RT-PCR_primers
==============

Use a seqFeatureStore database to with Primer3 to design primers sets in which at least one primer of a pair spans 
an exon with a product size between 100 and 150 bp. Provide the script with a text file of transcript (mRNA) names
that appear in the seqFeatureStore Database (GFF data structure) as well as a seqFeatureStore database base. 

**Requied** 
- Primer3 Release 2.3.5 or later.
- BioPerl

Example Usage:
==============
<pre>
cat genes
GRMZM2G006128_T02

perl getExonsForPrimers_inGene.pl maize.sqlite genes
ID      SEQLength       primerSetNum    primerOrient    product_size    start   len     tm      gc%     primerSeq
GRMZM2G006128_T02       2044    1       left    123     1058    22      59.776  50.000  CTTTCTGTTCTTCAAGACGCCC
GRMZM2G006128_T02       2044    1       right   123     1180    22      60.031  45.455  ATGCAACAACGGTAACTGAAGC
GRMZM2G006128_T02       2044    2       left    124     1057    22      59.776  50.000  CCTTTCTGTTCTTCAAGACGCC
GRMZM2G006128_T02       2044    2       right   124     1180    22      60.031  45.455  ATGCAACAACGGTAACTGAAGC
GRMZM2G006128_T02       2044    3       left    125     1056    22      59.776  50.000  CCCTTTCTGTTCTTCAAGACGC
GRMZM2G006128_T02       2044    3       right   125     1180    22      60.031  45.455  ATGCAACAACGGTAACTGAAGC
GRMZM2G006128_T02       2044    4       left    134     653     22      59.904  54.545  GTCACGTCAGCTAGGTCTACAG
GRMZM2G006128_T02       2044    4       right   134     786     22      59.838  45.455  TTCAGATTTGAGTGCGCATTCC
GRMZM2G006128_T02       2044    5       left    132     876     22      60.224  50.000  CCCAGCAAACATCATATGTGCC
GRMZM2G006128_T02       2044    5       right   132     1007    22      59.715  50.000  CAGATAATCGTTCTTGGCACGG
</pre>

Create a SeqFeatureStore database 
---------------------------------
1. use bp_seqfeature_load.pl. This script is a part of a collection of <a href="http://www.bioperl.org/wiki/Bioperl_scripts">BioPerl Scripts</a> that can be installed along with BioPerl. 
3.  MySQL or <a href="http://www.sqlite.org/">SQLite</a> is needed. 

Use SQLite if you can, it is easier to install and use.<br>
If you do use MySQL, the followging line in getExonsForPrimers_inGene.pl will need to be edited:
<pre>
-adaptor => 'DBI::SQLite',
</pre>
should be changed to 
<pre>
-adaptor => 'DBI::MySQL',
</pre>

How we created our Maize database
---------------------------------
1. Get GFF3: ftp://ftp.jgi-psf.org/pub/JGI_data/phytozome/v8.0/Zmays/annotation/Zmays_181_gene_exons.gff3.gz
- Get Genome FASTA: http://ftp.maizesequence.org/current/assembly/ZmB73_RefGen_v2.tar.gz
- To make the chromosome names the same in both the FASTA and GFF fils
- Due to inconsistencies in the names of chromosomes in the FASTA and GFF, the following code was used
to combine and rename FASTA files. This will be spefic for this version of the Maize assembly.

<pre>
for i in `ls *fasta` ; do j=`echo $i | awk -F '.' '{print $1}'` export j ; perl -pe  's/>(.+)/>$ENV{j} $1/' $i ; done > ZmB73_v2_renamed.fa
</pre>

- rename chromosomes in GFF file

<pre>
perl -pe 's/^(.+)\t/chr$1/' Zmays_181_gene.gff3 > Zmays_181_gene.renamed.gff3 
</pre> 

- bp_seqfeature_load.pl -d maize.sqlite -a DBI::SQLite -c -f Zmays_181_gene.renamed.gff3  



<pre>
bp_seqfeature_load.pl
Usage: /usr/local/bin/bp_seqfeature_load.pl [options] gff_file1 gff_file2...
  Options:
          -d --dsn        The database name (dbi:mysql:test)
          -s --seqfeature The type of SeqFeature to create (Bio::DB::SeqFeature)
          -a --adaptor    The storage adaptor to use (DBI::mysql)
          -v --verbose    Turn on verbose progress reporting
             --noverbose  Turn off verbose progress reporting
          -f --fast       Activate fast loading (only some adaptors)
          -T --temporary-directory  Specify temporary directory for fast loading (/tmp)
          -c --create     Create the database and reinitialize it (will erase contents)
          -u --user       User to connect to database as
          -p --password   Password to use to connect to database
          -S --subfeatures   Turn on indexing of subfeatures (default)
             --nosubfeatures Turn off indexing of subfeatures
          -i --ignore-seqregion
                          If true, then ignore ##sequence-region directives in the
                          GFF3 file (default, create a feature for each region)
          -z --zip        If true, database tables will be compressed to save space

Please see http://www.sequenceontology.org/gff3.shtml for information
about the GFF3 format. BioPerl extends the format slightly by adding 
a ##index-subfeatures directive. Set this to a true value if you wish 
the database to be able to retrieve a feature's individual parts (such as the
exons of a transcript) independently of the top level feature:

  ##index-subfeatures 1

It is also possible to control the indexing of subfeatures on a case-by-case
basis by adding "index=1" or "index=0" to the feature's attribute list. This
should only be used for subfeatures.

Subfeature indexing is true by default. Set to false (0) to save lots
of database space and speed performance. You may use --nosubfeatures
to force this.   
</pre>
