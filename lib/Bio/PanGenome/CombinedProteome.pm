package Bio::Roary::CombinedProteome;

# ABSTRACT: Take in multiple FASTA sequences containing proteomes and concat them together and output a FASTA file, filtering out more than 5% X's

=head1 SYNOPSIS

Take in multiple FASTA sequences containing proteomes and concat them together and output a FASTA file, filtering out more than 5% X's
   use Bio::Roary::CombinedProteome;
   
   my $obj = Bio::Roary::CombinedProteome->new(
     proteome_files   => ['abc.fa','efg.fa'],
     output_filename   => 'example_output.fa',
     maximum_percentage_of_unknowns => 5.0,
   );
   $obj->create_combined_proteome_file;

=cut

use Moose;
use Bio::Roary::Exceptions;

has 'proteome_files'                 => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'output_filename'                => ( is => 'ro', isa => 'Str',      default  => 'combined_output.fa' );

sub BUILD {
    my ($self) = @_;

    for my $filename ( @{ $self->proteome_files } ) {
        Bio::Roary::Exceptions::FileNotFound->throw( error => 'Cant open file: ' . $filename )
          unless ( -e $filename );
    }
}



sub create_combined_proteome_file {
    my ($self) = @_;
    
    unlink($self->output_filename);
    for my $filename (@{$self->proteome_files })
    {
       system(join(' ', ("cat", $filename, ">>", $self->output_filename)));
    }

    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
