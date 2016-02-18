undef $VERSION;
package Bio::Roary::CommandLine::CreatePanGenome;

# ABSTRACT: Take in FASTA files of proteins and cluster them

=head1 SYNOPSIS

Take in FASTA files of proteins and cluster them

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::Roary;
use Bio::Roary::PrepareInputFiles;
use Bio::Roary::QC::Report;
extends 'Bio::Roary::CommandLine::Roary';

has 'job_runner'                  => ( is => 'rw', isa => 'Str',  default => 'Local' );
has 'output_multifasta_files'     => ( is => 'rw', isa => 'Bool', default => 1 );
has 'dont_create_rplots'          => ( is => 'rw', isa => 'Bool', default => 0 );
has 'core_definition'             => ( is => 'rw', isa => 'Num',  default => 0.99 );
has 'run_qc'                      => ( is => 'rw', isa => 'Bool', default => 1 );

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
Usage:   create_pan_genome [options] *.gff
Build a pan genome with WTSI defaults.

Options: -p INT    number of threads [1]
         -o STR    clusters output filename [clustered_proteins]
		 -f STR    output directory [.]
         -e        create a multiFASTA alignment of core genes
         -n        fast core gene alignement with MAFFT, use with -e
         -i        minimum percentage identity for blastp [95]
         -cd FLOAT percentage of isolates a gene must be in to be core [99]
         -z        dont delete intermediate files
         -t INT    translation table [11]
         -v        verbose output to STDOUT
         -y        add gene inference information to spreadsheet, doesnt work with -e
         -g INT    maximum number of clusters [50000]
         -qc       generate QC report with Kraken
         -k STR    path to Kraken database for QC, use with -qc
         -w        print version and exit
		 -a        check dependancies and print versions
         -h        this help message

Example: Quickly generate a core gene alignment using 16 threads

         bsub.py --threads 16 10 log create_pan_genome -e --mafft -p 16  *.gff
         
Example: Allow Roary to bsub the jobs to LSF - you cant bsub this command itself

         create_pan_genome -j LSF -e --mafft -p 16  *.gff
		 
Example: Create a tree and visualise with iCANDY

		 annotationfind –t file –i file_of_lanes -symlink .
		 bsub.py --threads 16 10 log create_pan_genome -e --mafft -p 16 *.gff
		 ~sh16/scripts/run_RAxML.py -a core_gene_alignment.aln -q normal  -M 8 -n 8 -V AVX -o tree
		 bsub.py 10 log ~sh16/scripts/iCANDY.py -t RAxML_bipartitions.tree -q taxa -l 1 -E 30 -o accessory.pdf -M -L left -p A1 -g 90 accessory.tab accessory.header.embl

For further info see: http://mediawiki.internal.sanger.ac.uk/index.php/Pathogen_Informatics_Pan_Genome_Pipeline

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
