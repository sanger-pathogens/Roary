package Bio::Roary::JobRunner::LSF;

# ABSTRACT: Execute a set of commands using LSF

=head1 SYNOPSIS

Execute a set of commands using LSF
   use Bio::Roary::JobRunner::LSF;
   
   my $obj = Bio::Roary::JobRunner::LSF->new(
     commands_to_run   => ['ls', 'echo "abc"'],
   );
   $obj->run();

=cut

use Moose;
use LSF;
use LSF::JobManager;
use Bio::Roary::Exceptions;

has 'commands_to_run' => ( is => 'ro', isa => 'ArrayRef',        required => 1 );
has 'memory_in_mb'    => ( is => 'ro', isa => 'Int',             default  => 500 );
has 'queue'           => ( is => 'ro', isa => 'Str',             default  => 'normal' );
has '_job_manager'    => ( is => 'ro', isa => 'LSF::JobManager', lazy     => 1, builder => '_build__job_manager' );
has 'dont_wait'       => ( is => 'rw', isa => 'Bool',            default  => 0 );
has 'job_ids'         => ( is => 'ro', isa => 'ArrayRef',        default  => sub {[]} );

sub _build__job_manager {
    my ($self) = @_;
    return LSF::JobManager->new( -q => $self->queue );
}

sub _generate_memory_parameter {
    my ($self) = @_;
    return "select[mem > ".$self->memory_in_mb."] rusage[mem=".$self->memory_in_mb."]";
}

sub _submit_job {
    my ( $self, $command_to_run ) = @_;
    $self->_job_manager->submit(
        -o => "out.o",
        -e => "out.e",
        -M => $self->memory_in_mb,
        -R => $self->_generate_memory_parameter,
        $command_to_run
    );
}

sub _construct_dependancy_params
{
   my ($self, $ids) = @_;
   return '' if((! defined($ids)) || @{$ids} == 0);
   
   my @done_ids;
   for my $id ( @{$ids})
   {
     push(@done_ids, 'done('.$id.')');
   }
   return join('&&', @done_ids);
}


sub run {
    my ($self) = @_;
    for my $command_to_run ( @{ $self->commands_to_run } ) {
        my $job_id = $self->_submit_job($command_to_run);
        push(@{$self->job_ids}, $job_id->id);    
    }
    
    if(!(defined($self->dont_wait) && $self->dont_wait == 1 ))
    {
      $self->_job_manager->wait_all_children(history => 0);
    }
    1;
}

sub submit_dependancy_job {
    my ( $self,$command_to_run) = @_;
    $self->_job_manager->submit(
        -o => "out.o",
        -e => "out.e",
        -M => $self->memory_in_mb,
        -R => $self->_generate_memory_parameter,
        -w => $self->_construct_dependancy_params($self->job_ids),
        $command_to_run
    );
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
