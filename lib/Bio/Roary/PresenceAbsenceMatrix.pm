package Bio::Roary::PresenceAbsenceMatrix;

# ABSTRACT: Create a matrix with presence and absence

=head1 SYNOPSIS

Create a matrix with presence and absence. Since its computationally intensive to generate the inputs, calculate them once
in the GroupStatistics module and pass them through.
   use Bio::Roary::PresenceAbsenceMatrix;
   
   my $obj = Bio::Roary::PresenceAbsenceMatrix->new(
     annotate_groups_obj => $annotate_groups_obj,
     output_filename     => 'gene_presence_absence.Rtab',
     sorted_file_names   => $sorted_file_names,
     groups_to_files     => $groups_to_files,
     num_files_in_groups => $num_files_in_groups,
     sample_headers      => $sample_headers,
   );
   $obj->create_matrix_file;

=cut

use Moose;
use Text::CSV;
use Bio::SeqIO;
use Bio::Roary::Exceptions;
use Bio::Roary::AnnotateGroups;

has 'annotate_groups_obj' => ( is => 'ro', isa => 'Bio::Roary::AnnotateGroups', required => 1 );
has 'sorted_file_names'   => ( is => 'ro', isa => 'ArrayRef',                   required => 1 );
has 'groups_to_files'     => ( is => 'ro', isa => 'HashRef',                    required => 1 );
has 'num_files_in_groups' => ( is => 'ro', isa => 'HashRef',                    required => 1 );
has 'sample_headers'      => ( is => 'ro', isa => 'ArrayRef',                   required => 1 );
has 'output_filename'     => ( is => 'ro', isa => 'Str',                        default  => 'gene_presence_absence.Rtab' );

has '_output_fh' => ( is => 'ro', lazy => 1, builder => '_build__output_fh' );
has '_text_csv_obj' => ( is => 'ro', isa => 'Text::CSV', lazy => 1, builder => '_build__text_csv_obj' );

sub _build__output_fh {
    my ($self) = @_;
    open( my $fh, '>', $self->output_filename )
      or Bio::Roary::Exceptions::CouldntWriteToFile->throw( error => "Couldnt write output file:" . $self->output_filename );
    return $fh;
}

sub _build__text_csv_obj {
    my ($self) = @_;
    return Text::CSV->new( { binary => 1, always_quote => 0, sep_char => "\t", eol => "\r\n" } );
}

sub create_matrix_file {
    my ($self) = @_;

    # Header row
    unshift @{ $self->sample_headers }, 'Gene';
    $self->_text_csv_obj->print( $self->_output_fh, $self->sample_headers );

    for my $group ( sort { $self->num_files_in_groups->{$b} <=> $self->num_files_in_groups->{$a} || $a cmp $b }
        keys %{ $self->num_files_in_groups } )
    {
        my @row;
        my $annotated_group_name = $self->annotate_groups_obj->_groups_to_consensus_gene_names->{$group};
        push( @row, $annotated_group_name );
        for my $filename ( @{ $self->sorted_file_names } ) {
            my $group_to_file_genes = $self->groups_to_files->{$group}->{$filename};

            if ( defined($group_to_file_genes) && @{$group_to_file_genes} > 0 ) {
                push( @row, 1 );
                next;
            }
            else {
                push( @row, 0 );
            }
        }
        $self->_text_csv_obj->print( $self->_output_fh, \@row );
    }
	close( $self->_output_fh );
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
