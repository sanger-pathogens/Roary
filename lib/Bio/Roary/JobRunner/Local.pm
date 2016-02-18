package Bio::Roary::JobRunner::Local;

# ABSTRACT: Execute a set of commands locally

=head1 SYNOPSIS

 Execute a set of commands locally
   use Bio::Roary::JobRunner::Local;
   
   my $obj = Bio::Roary::JobRunner::Local->new(
     commands_to_run   => ['ls', 'echo "abc"'],
   );
   $obj->run();

=cut

use Moose;
use Log::Log4perl qw(:easy);

has 'commands_to_run' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'logger'          => ( is => 'ro', lazy => 1, builder => '_build_logger');
has 'verbose'         => ( is => 'rw', isa => 'Bool', default => 0 );
has 'memory_in_mb'    => ( is => 'rw', isa => 'Int',  default => '200' );

sub run {
    my ($self) = @_;

    for my $command_to_run ( @{ $self->commands_to_run } ) {  
        $self->logger->info($command_to_run);
        system($command_to_run );
    }
    1;
}


sub _construct_dependancy_params
{
  my ($self) = @_;
  return '';
}

sub submit_dependancy_job {
    my ( $self,$command_to_run) = @_;
    $self->logger->info($command_to_run);
    system($command_to_run );
}

sub _build_logger
{
    my ($self) = @_;
    my $level = $ERROR;
    if($self->verbose)
    {
       $level = $DEBUG;
    }
    Log::Log4perl->easy_init($level);
    my $logger = get_logger();
    return $logger;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
