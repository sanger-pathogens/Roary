package Bio::Roary::JobRunner::Role;

# ABSTRACT: A role to add job runner functionality

=head1 SYNOPSIS

A role to add job runner functionality
   with 'Bio::Roary::JobRunner::Role';

=cut

use Moose::Role;
use Log::Log4perl qw(:easy);
use File::Spec;

has 'job_runner'        => ( is => 'rw', isa => 'Str',  default  => 'Local' );
has '_job_runner_class' => ( is => 'ro', isa => 'Str',  lazy => 1, builder => '_build__job_runner_class' );
has 'memory_in_mb'      => ( is => 'rw', isa => 'Int',  default => '200' );
has '_queue'            => ( is => 'rw', isa => 'Str',  default => 'normal' );
has 'dont_wait'         => ( is => 'rw', isa => 'Bool', default => 0 );
has 'cpus'              => ( is => 'ro', isa => 'Int',      default => 1 );
has 'logger'            => ( is => 'ro', lazy => 1, builder => '_build_logger');
has 'verbose'           => ( is => 'rw', isa => 'Bool', default => 0 );

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

sub _build__job_runner_class {
    my ($self) = @_;
    my $job_runner_class = "Bio::Roary::JobRunner::" . $self->job_runner;
    eval "require $job_runner_class";
    return $job_runner_class;
}

sub _find_exe {
  my($self,$executables) = @_;
  
  # If there is an explicit full path passed in, just return.
  if($executables->[0] =~ m!/!)
  {
	  return $executables->[0];
  }
  
  for my $dir (File::Spec->path) {
	  for my $exec (@{$executables})
	  {
        my $exe = File::Spec->catfile($dir, $exec);
        return $exe if -x $exe; 
      }
  }
  return $executables->[0];
}


1;
