undef $VERSION;
package Bio::Roary::CommandLine::RoaryCoreAlignment;

# ABSTRACT: Take in the group statistics spreadsheet and the location of the gene multifasta files and create a core alignment.

=head1 SYNOPSIS

Take in the group statistics spreadsheet and the location of the gene multifasta files and create a core alignment.

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Cwd 'abs_path';
use File::Path qw(remove_tree);
use Bio::Roary::ExtractCoreGenesFromSpreadsheet;
use Bio::Roary::LookupGeneFiles;
use Bio::Roary::MergeMultifastaAlignments;
extends 'Bio::Roary::CommandLine::Common';

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'multifasta_base_directory' => ( is => 'rw', isa => 'Str', default => 'pan_genome_sequences' );
has 'spreadsheet_filename'      => ( is => 'rw', isa => 'Str', default => 'gene_presence_absence.csv' );
has 'output_filename'           => ( is => 'rw', isa => 'Str', default => 'core_gene_alignment.aln' );
has 'core_definition'           => ( is => 'rw', isa => 'Num', default => 0.99 );
has 'dont_delete_files'         => ( is => 'rw', isa => 'Bool', default => 0 );
has '_error_message'            => ( is => 'rw', isa => 'Str' );
has 'verbose'                   => ( is => 'rw', isa => 'Bool', default => 0 );

sub BUILD {
    my ($self) = @_;

    my ( $multifasta_base_directory, $spreadsheet_filename, $output_filename, $core_definition,$verbose,  $help, $mafft, $dont_delete_files );

    GetOptionsFromArray(
        $self->args,
        'm|multifasta_base_directory=s' => \$multifasta_base_directory,
        's|spreadsheet_filename=s'      => \$spreadsheet_filename,
        'o|output_filename=s'           => \$output_filename,
        'cd|core_definition=f'          => \$core_definition,
        'z|dont_delete_files'           => \$dont_delete_files,
		'v|verbose'                     => \$verbose,
        'h|help'                        => \$help,
    );
    
    if ( defined($verbose) ) {
        $self->verbose($verbose);
        $self->logger->level(10000);
    }
    $self->help($help) if(defined($help));

    if ( defined($multifasta_base_directory) && ( -d $multifasta_base_directory ) ) {
        $self->multifasta_base_directory( abs_path($multifasta_base_directory));
    }
    if(! -d $self->multifasta_base_directory ) 
    {
        $self->_error_message("Error: Cant access the multifasta base directory: ".$self->multifasta_base_directory);
    }
    
    if ( defined($spreadsheet_filename) && ( -e $spreadsheet_filename ) ) {
        $self->spreadsheet_filename( abs_path($spreadsheet_filename));
    }
    if(! -e $self->spreadsheet_filename ) 
    {
        $self->_error_message("Error: Cant access the spreadsheet: ".$self->spreadsheet_filename);
    }
    $self->output_filename( $output_filename ) if ( defined($output_filename) );
    if ( defined($core_definition) ) 
	{
		if($core_definition > 1)
		{
			$self->core_definition( $core_definition/100 );
		}
		else
		{
			$self->core_definition( $core_definition );
		}
	}
    $self->dont_delete_files($dont_delete_files) if ( defined($dont_delete_files) );
    
}

sub run {
    my ($self) = @_;

    ( !$self->help ) or die $self->usage_text;
    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }

	$self->logger->info("Extract core genes from spreadsheet");
    my $core_genes_obj = Bio::Roary::ExtractCoreGenesFromSpreadsheet->new( 
        spreadsheet     => $self->spreadsheet_filename,
        core_definition => $self->core_definition
    );
	
	$self->logger->info("Looking up genes in files");
    my $gene_files = Bio::Roary::LookupGeneFiles->new(
        multifasta_directory => $self->multifasta_base_directory,
        ordered_genes        => $core_genes_obj->ordered_core_genes,
      );
	 
	$self->logger->info("Merge multifasta alignments");
    my $merge_alignments_obj = Bio::Roary::MergeMultifastaAlignments->new(
	  sample_names          => $core_genes_obj->sample_names,
      multifasta_files      => $gene_files->ordered_gene_files(),
      output_filename       => $self->output_filename,
	  sample_names_to_genes => $core_genes_obj->sample_names_to_genes
    );
    $merge_alignments_obj->merge_files;
    
    if($self->dont_delete_files == 0)
    {
      remove_tree('pan_genome_sequences');
    }
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
Usage: pan_genome_core_alignment [options]
Create an alignment of core genes from the spreadsheet and the directory of gene multi-FASTAs.

Options: -o STR    output filename [core_gene_alignment.aln]
         -cd FLOAT percentage of isolates a gene must be in to be core [99]
         -m STR    directory containing gene multi-FASTAs [pan_genome_sequences]
         -s STR    gene presence and absence spreadsheet [gene_presence_absence.csv]
         -z        dont delete intermediate files
         -v        verbose output to STDOUT
         -h        this help message

For further info see: http://sanger-pathogens.github.io/Roary/
USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
