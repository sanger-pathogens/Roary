package Bio::PanGenome::External::Mcl;

# ABSTRACT: Wrapper around MCL which takes in blast results and outputs clustered results

=head1 SYNOPSIS

Wrapper around MCL which takes in blast results and outputs clustered results

   use Bio::PanGenome::External::Mcl;
   
   my $mcl= Bio::PanGenome::External::Mcl->new(
     blast_results     => 'db',
     mcxdeblast_exec   => 'mcxdeblast',
     mcl_exec          => 'mcl',
     output_file       => 'output.groups'
   );
   
   $mcl->run();

=cut

use Moose;

has 'blast_results'   => ( is => 'ro', isa => 'Str', required => 1 );
has 'mcxdeblast_exec' => ( is => 'ro', isa => 'Str', default  => 'mcxdeblast' );
has 'mcl_exec'        => ( is => 'ro', isa => 'Str', default  => 'mcl' );
has 'output_file'     => ( is => 'ro', isa => 'Str', default  => 'output_groups' );

has '_inflation_value' => ( is => 'ro', isa => 'Num', default => 1.5 );
has '_logging'          => ( is => 'ro', isa => 'Str', default  => '2> /dev/null' );

sub _command_to_run {
    my ($self) = @_;
    return join(
        " ",
        (
            $self->mcxdeblast_exec, '-m9', 
            '--line-mode=abc', $self->blast_results, 
            '|', $self->mcl_exec, '-', '--abc',
            '-I', $self->_inflation_value, '-o', $self->output_file, 
            $self->_logging
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
