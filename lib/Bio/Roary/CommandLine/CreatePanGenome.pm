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
has 'output_multifasta_files'     => ( is => 'rw', isa => 'Bool', default => 0 );
has 'dont_create_rplots'          => ( is => 'rw', isa => 'Bool', default => 0 );
has 'core_definition'             => ( is => 'rw', isa => 'Num',  default => 0.99 );
has 'run_qc'                      => ( is => 'rw', isa => 'Bool', default => 1 );

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: create_pan_genome [options]
    This script sets the defaults for use in the Pathogen Genomics group at WTSI.
	The only differences are that it runs additional analysis by default 
	(which are turned off to make Roary as easy as possible to install & run for external users ):
	 - QC of samples with Kraken
	 - MultiFASTA core alignment of core genes
	 - Core is defined as being in 99% of isolates
	 - A PDF of plots is created with R
    
    For more details see:
    http://mediawiki.internal.sanger.ac.uk/index.php/Pathogen_Informatics_Pan_Genome_Pipeline
    

    # Take in GFF files and cluster the genes
    bsub  -M4000 -R "select[mem>4000] rusage[mem=4000]" 'create_pan_genome example.gff'
	
    # Run with 16 processors and 10GB of RAM
    bsub -q long -o log -e err -M10000 -R "select[mem>10000] rusage[mem=10000]" -n16 -R "span[hosts=1]" 'create_pan_genome -p 16  *.gff'
	

	########### 
	
    # Create multifasta alignement of each gene (Warning: Thousands of files are created)
    create_pan_genome -e --dont_delete_files *.gff
	
    # Create a MultiFASTA alignment of core genes where core is defined as being in at least 98% of isolates (default 99%)
    create_pan_genome -e --core_definition 98 *.gff
	
    # Set the blastp percentage identity threshold (default 95%).
    create_pan_genome -i 98 *.gff
    
    # Different translation table (default is 11 for Bacteria). Viruses/Vert = 1
    create_pan_genome --translation_table 1 *.gff 
	
    # Verbose output to STDOUT so that you know whats happening as it goes along
    create_pan_genome -v *.gff

    # Include full annotation and inference in group statistics
    create_pan_genome --verbose_stats *.gff

    # Increase the groups/clusters limit (default 50,000). Please check the QC results before running this!
    create_pan_genome --group_limit 60000  *.gff
    
    # Use a different Kraken database
    roary -k /path/to/kraken_database/  *.gff

    # This help message
    create_pan_genome -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
