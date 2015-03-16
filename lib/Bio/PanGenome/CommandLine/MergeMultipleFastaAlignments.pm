package Bio::PanGenome::CommandLine::MergeMultipleFastaAlignments;

# ABSTRACT: Take in a list of alignment files with equal numbers of sequences and merge them.

=head1 SYNOPSIS

Take in a list of alignment files with equal numbers of sequences and merge them.

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::PanGenome::MergeMultifastaAlignments;
extends 'Bio::PanGenome::CommandLine::Common';

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );

has 'fasta_files'      => ( is => 'rw', isa => 'ArrayRef' );
has 'output_filename'  => ( is => 'rw', isa => 'Str', default => 'merged_alignments.aln' );
has '_error_message'   => ( is => 'rw', isa => 'Str' );

sub BUILD {
    my ($self) = @_;

    my ( $fasta_files,$output_filename, $help );

    GetOptionsFromArray(
        $self->args,
        'o|output_filename=s'   => \$output_filename,
        'h|help'              => \$help,
    );

    $self->help($help) if(defined($help));
    if ( @{ $self->args } < 2 ) {
        $self->_error_message("Error: You need to provide at least 2 FASTA files");
    }
    $self->output_filename($output_filename) if ( defined($output_filename) );

    for my $filename ( @{ $self->args } ) {
        if ( !-e $filename ) {
            $self->_error_message("Error: Cant access file $filename");
            last;
        }
    }
    $self->fasta_files( $self->args );
}

sub run {
    my ($self) = @_;

    ( !$self->help ) or die $self->usage_text;
    if ( defined( $self->_error_message ) ) {
        print $self->_error_message . "\n";
        die $self->usage_text;
    }

    my $obj = Bio::PanGenome::MergeMultifastaAlignments->new(
      multifasta_files => $self->fasta_files,
      output_filename  => $self->output_filename
    );
    $obj->merge_files;
}

sub usage_text {
    my ($self) = @_;

    return <<USAGE;
    Usage: merge_multifasta_alignments [options]
    Take in a list of alignment files with equal numbers of sequences and merge them.
    
    # Merge a list of files
    merge_multifasta_alignments  multifasta_1.aln multifasta_2.aln multifasta_3.aln
    
    # provide an output file name
    merge_multifasta_alignments -o output.aln multifasta_1.aln multifasta_2.aln
    
    # This help message
    merge_multifasta_alignments -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
