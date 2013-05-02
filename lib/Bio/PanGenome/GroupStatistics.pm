package Bio::PanGenome::GroupStatistics;

# ABSTRACT: Add labels to the groups

=head1 SYNOPSIS

Add labels to the groups
   use Bio::PanGenome::GroupStatistics;
   
   my $obj = Bio::PanGenome::GroupStatistics->new(
     output_filename => 'group_statitics.csv',
     annotate_groups_obj => $annotate_groups_obj,
     analyse_groups_obj  => $analyse_groups_obj
   );
   $obj->create_spreadsheet;

=cut

use Moose;
use POSIX;
use Text::CSV;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::AnalyseGroups;
use Bio::PanGenome::AnnotateGroups;

has 'annotate_groups_obj' => ( is => 'ro', isa => 'Bio::PanGenome::AnnotateGroups', required => 1 );
has 'analyse_groups_obj'  => ( is => 'ro', isa => 'Bio::PanGenome::AnalyseGroups',  required => 1 );
has 'output_filename'     => ( is => 'ro', isa => 'Str',                            default  => 'group_statitics.csv' );

has '_output_fh' => ( is => 'ro', lazy => 1, builder => '_build__output_fh' );
has '_text_csv_obj' => ( is => 'ro', isa => 'Text::CSV', lazy => 1, builder => '_build__text_csv_obj' );

sub _build__output_fh {
    my ($self) = @_;
    open( my $fh, '>', $self->output_filename )
      or Bio::PanGenome::Exceptions::CouldntWriteToFile->throw(
        error => "Couldnt write output file:" . $self->output_filename );
    return $fh;
}

sub _build__text_csv_obj {
    my ($self) = @_;
    return Text::CSV->new( { binary => 1, always_quote => 1, eol => "\r\n" } );
}

sub _header {
    my ($self) = @_;
    return [ 'Gene', 'Annotation', 'No. isolates', 'No. sequences', 'Avg sequences per isolate', 'Gene IDs' ];
}

sub _row {
    my ( $self, $group ) = @_;
    my $genes = $self->analyse_groups_obj->_groups_to_genes->{$group};

    my $num_isolates_in_group     = $self->analyse_groups_obj->_count_num_files_in_group($genes);
    my $num_sequences_in_group    = $#{$genes} + 1;
    my $avg_sequences_per_isolate = ceil( ( $num_sequences_in_group / $num_isolates_in_group ) * 100 ) / 100;

    my $annotation           = $self->annotate_groups_obj->_ids_to_product->{ $genes->[0] };
    my $annotated_group_name = $self->annotate_groups_obj->_groups_to_consensus_gene_names->{$group};

    return [
        $annotated_group_name,   $annotation,                $num_isolates_in_group,
        $num_sequences_in_group, $avg_sequences_per_isolate, @{$genes}
    ];
}

sub create_spreadsheet {
    my ($self) = @_;

    $self->_text_csv_obj->print( $self->_output_fh, $self->_header );

    for my $group (
        sort {
            $self->analyse_groups_obj->_count_num_files_in_group( $self->analyse_groups_obj->_groups_to_genes->{$b} )
              <=> $self->analyse_groups_obj->_count_num_files_in_group(
                $self->analyse_groups_obj->_groups_to_genes->{$a} )
        } @{ $self->analyse_groups_obj->_groups }
      )
    {
        $self->_text_csv_obj->print( $self->_output_fh, $self->_row($group) );
    }
    close( $self->_output_fh );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
