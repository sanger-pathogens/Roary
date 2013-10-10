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
with 'Bio::PanGenome::JobRunner::Role';

has 'blast_results'   => ( is => 'ro', isa => 'Str', required => 1 );
has 'mcxdeblast_exec' => ( is => 'ro', isa => 'Str', default  => 'mcxdeblast' );
has 'mcl_exec'        => ( is => 'ro', isa => 'Str', default  => 'mcl' );
has 'output_file'     => ( is => 'ro', isa => 'Str', default  => 'output_groups' );

has '_inflation_value' => ( is => 'ro', isa => 'Num', default => 1.5 );
has '_logging'         => ( is => 'ro', isa => 'Str', default  => '2> /dev/null' );

has '_memory_required_in_mb'  => ( is => 'ro', isa => 'Int',  lazy => 1, builder => '_build__memory_required_in_mb' );

sub _build__memory_required_in_mb
{
  my ($self) = @_;
  # Todo: implement this equation for memory estimation if this hardcoded value proves too unstable.
  # http://micans.org/mcl/man/mcl.html#opt-how-much-ram
  return 1000;
}


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
    my @commands_to_run;
    push(@commands_to_run, $self->_command_to_run );
    
    my $job_runner_obj = $self->_job_runner_class->new( commands_to_run => \@commands_to_run, memory_in_mb => $self->_memory_required_in_mb, queue => $self->_queue );
    $job_runner_obj->run();
    
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
