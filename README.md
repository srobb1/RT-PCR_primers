RT-PCR_primers
==============

use a seqFeatureStore database to create sequence to use with Primer3 for primers that span exons

Requied** libprimer3 release 2.3.5 or later.


Create a SeqFeatureStore database 
---------------------------------
1. use bp_seqfeature_load.pl. This script comes with the BioPerl installation.
2. More info on <a href="http://www.bioperl.org/wiki/Bioperl_scripts">BioPerl Scripts</a>
3. Need MySQL or <a href="http://www.sqlite.org/">SQlite</a>. 

Use SQlite if you can, it is easier to install and use.<br>
If you do use MySQL, this line in getExonsForPrimers_inGene.pl:
<pre>
-adaptor => 'DBI::SQLite',
</pre>
should be changed to 
<pre>
-adaptor => 'DBI::MySQL',
</pre>

How we created our Maize database
---------------------------------
3. the options we used to create our Maize database
- Get GFF3: ftp://ftp.jgi-psf.org/pub/JGI_data/phytozome/v8.0/Zmays/annotation/Zmays_181_gene_exons.gff3.gz
- Get Genome FASTA: http://ftp.maizesequence.org/current/assembly/ZmB73_RefGen_v2.tar.gz
- To make the chromosome names the same in both the FASTA and GFF fils
- combine and rename FASTA files
- <pre>
for i in `ls *fasta` ; do j=`echo $i | awk -F '.' '{print $1}'` export j ; perl -pe  's/>(.+)/>$ENV{j} $1
/' $i ; done > ZmB73_v2_renamed.fa
- rename chromosomes in GFF file
- <pre>
perl -pe 's/^(.+)\t/chr$1/' Zmays_181_gene.gff3 > Zmays_181_gene.renamed.gff3 
</pre> 
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
