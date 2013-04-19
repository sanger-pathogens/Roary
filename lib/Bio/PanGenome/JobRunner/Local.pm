package Bio::PanGenome::JobRunner::Local;

# ABSTRACT: Execute a set of commands locally

=head1 SYNOPSIS

 Execute a set of commands locally
   use Bio::PanGenome::JobRunner::Local;
   
   my $obj = Bio::PanGenome::JobRunner::Local->new(
     commands_to_run   => ['ls', 'echo "abc"'],
   );
   $obj->run();

=cut

use Moose;

has 'commands_to_run' => ( is => 'ro', isa => 'ArrayRef', required => 1 );

sub run {
    my ($self) = @_;

    for my $command_to_run ( @{ $self->commands_to_run } ) {
        system($command_to_run );
    }
    1;
}
no Moose;
__PACKAGE__->meta->make_immutable;

1;
