package Bio::Roary::External::Mcl;

# ABSTRACT: Wrapper around MCL which takes in blast results and outputs clustered results

=head1 SYNOPSIS

Wrapper around MCL which takes in blast results and outputs clustered results

   use Bio::Roary::External::Mcl;
   
   my $mcl= Bio::Roary::External::Mcl->new(
     blast_results     => 'db',
     mcxdeblast_exec   => 'mcxdeblast',
     mcl_exec          => 'mcl',
     output_file       => 'output.groups'
   );
   
   $mcl->run();

=cut

use Moose;
use File::Which;
with 'Bio::Roary::JobRunner::Role';

has 'blast_results'   => ( is => 'ro', isa => 'Str', required => 1 );
has 'mcxdeblast_exec' => ( is => 'ro', isa => 'Str', default  => 'mcxdeblast' );
has '_full_mcxdeblast_exec' =>  ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__full_mcxdeblast_exec');
has 'mcl_exec'        => ( is => 'ro', isa => 'Str', default  => 'mcl' );
has 'output_file'     => ( is => 'ro', isa => 'Str', default  => 'output_groups' );

has '_score'     => ( is => 'ro', isa => 'Str', default  => 'r' );

has 'inflation_value' => ( is => 'ro', isa => 'Num', default => 1.5 );
has '_logging'         => ( is => 'ro', isa => 'Str', default  => '> /dev/null 2>&1' );

has 'memory_in_mb'  => ( is => 'ro', isa => 'Int',  lazy => 1, builder => '_build_memory_in_mb' );

sub _build_memory_in_mb
{
  my ($self) = @_;
  # Todo: implement this equation for memory estimation if this hardcoded value proves too unstable.
  # http://micans.org/mcl/man/mcl.html#opt-how-much-ram
  
  my $filename = $self->blast_results;
  my $memory_required = 2000;
  if(-e $filename)
  {
    $memory_required = -s $filename;
    # Convert to mb
    $memory_required = int($memory_required/1000000);
    # increase memory for worst case senario
    $memory_required *= 3;
    $memory_required += 2000;
  }

  return  $memory_required;
}


sub _build__full_mcxdeblast_exec
{
	my ($self) = @_;
	
	if(-e $self->mcxdeblast_exec)
	{
		return $self->mcxdeblast_exec;
	}
	
	my $full_exec = which($self->mcxdeblast_exec);	
	if(! defined($full_exec))
	{
		$self->logger->error("Cannot find the mcxdeblast executable, please ensure its in your PATH") ;
		exit();
	}
	return "perl $full_exec";
}

sub _command_to_run {
    my ($self) = @_;
    return join(
        " ",
        (
            $self->_full_mcxdeblast_exec, '-m9', '--score='.$self->_score,
            '--line-mode=abc', $self->blast_results, '2> /dev/null',
            '|', $self->mcl_exec, '-', '--abc',
            '-I', $self->inflation_value, '-o', $self->output_file, 
            $self->_logging
        )
    );
}

sub run {
    my ($self) = @_;
    my @commands_to_run;
    push(@commands_to_run, $self->_command_to_run );
    $self->logger->info( "Running command: " . $self->_command_to_run() );
    my $job_runner_obj = $self->_job_runner_class->new( commands_to_run => \@commands_to_run, memory_in_mb => $self->memory_in_mb, queue => $self->_queue,        cpus            => $self->cpus  );
    $job_runner_obj->run();
    
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
