package Bio::PanGenome::CommandLine::PanGenomeCoreAlignment;

# ABSTRACT: Take in the group statistics spreadsheet and the location of the gene multifasta files and create a core alignment.

=head1 SYNOPSIS

Take in the group statistics spreadsheet and the location of the gene multifasta files and create a core alignment.

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Cwd 'abs_path';
use Bio::PanGenome::ExtractCoreGenesFromSpreadsheet;
use Bio::PanGenome::LookupGeneFiles;
use Bio::PanGenome::MergeMultifastaAlignments;

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'multifasta_base_directory' => ( is => 'rw', isa => 'Str', default => 'pan_genome_sequences' );
has 'spreadsheet_filename'      => ( is => 'rw', isa => 'Str', default => 'group_statisics.csv' );
has 'output_filename'           => ( is => 'rw', isa => 'Str', default => 'core_gene_alignment.aln' );
has '_error_message'            => ( is => 'rw', isa => 'Str' );

sub BUILD {
    my ($self) = @_;

    my ( $multifasta_base_directory, $spreadsheet_filename, $output_filename, $help );

    GetOptionsFromArray(
        $self->args,
        'm|multifasta_base_directory=s' => \$multifasta_base_directory,
        's|spreadsheet_filename=s'      => \$spreadsheet_filename,
        'o|output_filename=s'           => \$output_filename,
        'h|help'                        => \$help,
    );

    if ( defined($multifasta_base_directory) && ( -d $multifasta_base_directory ) ) {
        $self->multifasta_base_directory( abs_path($multifasta_base_directory));
    }
    if(! -d $self->multifasta_base_directory ) 
    {
        $self->_error_message("Error: Cant access the multifasta base directory $multifasta_base_directory");
    }
    
    if ( defined($spreadsheet_filename) && ( -e $spreadsheet_filename ) ) {
        $self->spreadsheet_filename( abs_path($spreadsheet_filename));
    }
    if(! -e $self->spreadsheet_filename ) 
    {
        $self->_error_message("Error: Cant access the spreadsheet $spreadsheet_filename");
    }

    $self->output_filename( $output_filename) if ( defined($output_filename));

}

sub run {
    my ($self) = @_;

    ( !$self->help ) or die $self->usage_text;
    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }

    my $core_genes_obj = Bio::PanGenome::ExtractCoreGenesFromSpreadsheet->new( spreadsheet  => $self->spreadsheet_filename);
    
    my $gene_files = Bio::PanGenome::LookupGeneFiles->new(
        multifasta_directory => $self->multifasta_base_directory,
        ordered_genes        => $core_genes_obj->ordered_core_genes,
      );
    
    my $merge_alignments_obj = Bio::PanGenome::MergeMultifastaAlignments->new(
      multifasta_files => $gene_files->ordered_gene_files(),
      output_filename  => $self->output_filename
    );
    $merge_alignments_obj->merge_files;
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: pan_genome_core_alignment [options]
    Create a core alignment from the spreadsheet and the directory of multifasta gene files.
    Genes are ordered based on order in de novo assemblies.
    
    # When run from the directory where the pan genome exists, it should just work
    pan_genome_core_alignment
    
    # Specify the directory containing the multifastas (-m), the spreadsheet (-s) and an output file name (-o)
    pan_genome_core_alignment -m pan_genome_sequences -s group_statisics.csv -o output_alignment.aln
    
    # This help message
    pan_genome_core_alignment -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
