package Bio::PanGenome::External::Segmasker;

# ABSTRACT: Wrapper around Segmasker for low complexity filtering

=head1 SYNOPSIS

Wrapper around Segmasker for low complexity filtering

   use Bio::PanGenome::External::Segmasker;
   
   my $seg= Bio::PanGenome::External::Segmasker->new(
     fasta_file => 'contigs.fa',
   );
   
   $seg->run();

=method output_file

Returns the path to the results file

=cut

use Moose;

has 'fasta_file'        => ( is => 'ro', isa => 'Str', required => 1 );
has 'exec'              => ( is => 'ro', isa => 'Str', default  => 'segmasker' );
has 'output_file'       => ( is => 'ro', isa => 'Str', default  => 'database_masking.asnb' );
has '_infmt'            => ( is => 'ro', isa => 'Str', default  => 'fasta' );
has '_outfmt'           => ( is => 'ro', isa => 'Str', default  => 'maskinfo_asn1_bin' );

sub _command_to_run {
    my ($self) = @_;
    return join(
        " ",
        (
            $self->exec,  
            '-in',           $self->fasta_file, 
            '-infmt',        $self->_infmt,
            '-parse_seqids', 
            '-outfmt',       $self->_outfmt,
            '-out',          $self->output_file
        )
    );
}

sub run {
    my ($self) = @_;
    system( $self->_command_to_run );
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
