RT-PCR_primers
==============

use a seqFeatureStore database to create sequence to use with Primer3 for primers that span exons

need libprimer3 release 2.3.5 or later.


Create a SeqFeatureStore database 
---------------------------------
- use bp_seqfeature_load.pl. This script come with the BioPerl installation.
- More info on <a href="http://www.bioperl.org/wiki/Bioperl_scripts">BioPerl Scripts</a>


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
