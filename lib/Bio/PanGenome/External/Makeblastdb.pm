package Bio::PanGenome::External::Makeblastdb;

# ABSTRACT: Wrapper around NCBIs makeblastdb command

=head1 SYNOPSIS

Take in a fasta file and create a temporary blast database.

   use Bio::PanGenome::External::Makeblastdb;
   
   my $blast_database= Bio::PanGenome::External::Makeblastdb->new(
     fasta_file => 'contigs.fa',
     exec       => 'makeblastdb'
   );
   
   $blast_database->run();

=method output_database

Returns the path to the temporary blast database files

=cut

use Moose;
use File::Temp;
use Cwd;

has 'fasta_file'         => ( is => 'ro', isa => 'Str', required => 1 );
has 'exec'               => ( is => 'ro', isa => 'Str', default  => 'makeblastdb' );
has '_working_directory' => ( is => 'ro', isa => 'File::Temp::Dir', default  => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );
has '_dbtype'            => ( is => 'ro', isa => 'Str', default  => 'prot' );
has '_logfile'           => ( is => 'ro', isa => 'Str', default  => '/dev/null' );
has 'output_database'    => ( is => 'ro', isa => 'Str', lazy     => 1, builder => '_build_output_database' );

sub _build_output_database {
    my ($self) = @_;
    return join( '/', ( $self->_working_directory->dirname(), 'output_contigs' ) );
}

sub _command_to_run {
    my ($self) = @_;
    return join(
        " ",
        (
            $self->exec,    
            '-in',      $self->fasta_file,       
            '-dbtype',  $self->_dbtype, 
            '-out',     $self->output_database, 
            '-logfile', $self->_logfile
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
