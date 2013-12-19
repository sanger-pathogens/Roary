package Bio::PanGenome::External::Revtrans;

# ABSTRACT: Wrapper around RevTrans

=head1 SYNOPSIS

Take in a fasta file and create a temporary blast database.

   use Bio::PanGenome::External::Revtrans;
   
   my $blast_database= Bio::PanGenome::External::Revtrans->new(
     nucleotide_filename => 'contigs.fa',
     protein_filename  => 'proteins.faa'
     output_filename   => 'translated.fa.aln'
   );
   
   $blast_database->run();

=cut

use Moose;

has 'nucleotide_filename'  => ( is => 'ro', isa => 'Str', required => 1 );
has 'protein_filename'     => ( is => 'ro', isa => 'Str', required => 1  );
has 'output_filename'      => ( is => 'ro', isa => 'Str', required => 1  );
has 'exec'                 => ( is => 'ro', isa => 'Str', default  => 'revtrans.py' );


sub _command_to_run {
    my ($self) = @_;
    return join(
        " ",
        (
            $self->exec,      
            $self->nucleotide_filename,
            $self->protein_filename,
            '-mtx', 11,
            '-readthroughstop',
            '-allinternal', 
            '-match', 'name',
            '>', $self->output_filename
        )
    );
}

sub run {
  my ($self) = @_;
  my $cmd = $self->_command_to_run;
  system($cmd);
  1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
