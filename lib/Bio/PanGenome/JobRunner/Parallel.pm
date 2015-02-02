package Bio::PanGenome::JobRunner::Parallel;

# ABSTRACT: Use GNU Parallel

=head1 SYNOPSIS

 Execute a set of commands using GNU parallel
   use Bio::PanGenome::JobRunner::Parallel;
   
   my $obj = Bio::PanGenome::JobRunner::Local->new(
     commands_to_run   => ['ls', 'echo "abc"'],
     max_jobs => 4
   );
   $obj->run();

=cut

use Moose;
use File::Slurp;
use File::Temp qw/ tempfile /;

has 'commands_to_run' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'cpus'            => ( is => 'ro', isa => 'Int',      default => 1 );

sub run {
    my ($self) = @_;
    my ($fh, $filename) = tempfile();
    write_file( $fh, join("\n", @{ $self->commands_to_run }) ) ;
  
    my $parallel_command = "cat $filename | parallel -j ".$self->cpus;
    system($parallel_command);
    1;
}

sub _construct_dependancy_params
{
  my ($self) = @_;
  return '';
}

sub submit_dependancy_job {
    my ( $self,$command_to_run) = @_;
    system($command_to_run );
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
