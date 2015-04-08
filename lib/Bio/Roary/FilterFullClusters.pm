package Bio::Roary::FilterFullClusters;

# ABSTRACT: Take an a clusters file from CD-hit and the fasta file and output a fasta file without full clusters

=head1 SYNOPSIS

Take an a clusters file from CD-hit and the fasta file and output a fasta file without full clusters
   use Bio::Roary::FilterFullClusters;
   
   my $obj = Bio::Roary::FilterFullClusters->new(
       clusters_filename        => $cluster_file,
       fasta_file           => $fasta_file,
       number_of_input_files => 10,
       output_file => 'filtered_file'
     );
   $obj->filter_full_clusters_from_fasta();

=cut

use Moose;
use Bio::SeqIO;
with 'Bio::Roary::ClustersRole';

has 'number_of_input_files' => ( is => 'ro', isa => 'Int', required => 1 );
has 'fasta_file'     => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_file'    => ( is => 'ro', isa => 'Str', required => 1 );
has '_greater_than_or_equal' =>  ( is => 'ro', isa => 'Bool', default => 0 );
has 'cdhit_input_fasta_file'    => ( is => 'ro', isa => 'Str', required => 1 );
has 'cdhit_output_fasta_file'    => ( is => 'ro', isa => 'Str', required => 1 );

has 'output_groups_file' => ( is => 'ro', isa => 'Str', required => 1 );

has '_full_cluster_gene_names'    => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build__full_cluster_gene_names' );
has '_input_seqio'  => ( is => 'ro', isa => 'Bio::SeqIO', lazy => 1, builder => '_build__input_seqio' );
has '_output_seqio' => ( is => 'ro', isa => 'Bio::SeqIO', lazy => 1, builder => '_build__output_seqio' );

has '_all_full_cluster_genes'    => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build__all_full_cluster_genes' );

sub _build__full_cluster_gene_names
{
  my($self) = @_;
  
  my %full_cluster_gene_names ;
  
  for my $gene_name (keys %{$self->_clustered_genes})
  {
  
    if($self->_greater_than_or_equal == 0)
    {
      if(defined($self->_clustered_genes->{$gene_name}) && @{$self->_clustered_genes->{$gene_name}} >= ($self->number_of_input_files -1))
      {
        $full_cluster_gene_names{$gene_name}++;
      }
    }
    else
    {
      if(defined($self->_clustered_genes->{$gene_name}) && @{$self->_clustered_genes->{$gene_name}} == ($self->number_of_input_files -1))
      {
        $full_cluster_gene_names{$gene_name}++;
      }
    }
  }
  
  return \%full_cluster_gene_names;
}

sub _build__input_seqio {
    my ($self) = @_;
    return Bio::SeqIO->new( -file => $self->fasta_file, -format => 'Fasta' );
}

sub _build__output_seqio {
    my ( $self, $chunk_number ) = @_;
    return Bio::SeqIO->new( -file => ">".$self->output_file, -format => 'Fasta' );
}

sub _build__all_full_cluster_genes
{
   my ($self) = @_;
   my %full_cluster_genes;
   
   for my $gene_name (keys %{$self->_full_cluster_gene_names})
   {
     $full_cluster_genes{$gene_name}++;
     for my $cluster_gene_name (@{$self->_clustered_genes->{$gene_name}})
     {
       $full_cluster_genes{$cluster_gene_name}++;
     }
   }
   return \%full_cluster_genes;
}


sub _create_groups_file
{
  my ($self) = @_;
  open(my $out_fh, '>>', $self->output_groups_file);
  
  for my $gene_name (keys %{$self->_full_cluster_gene_names})
  {
    print {$out_fh} $gene_name."\t". join("\t", @{$self->_clustered_genes->{$gene_name}}). "\n";
  }
  close($out_fh);
}



sub filter_complete_cluster_from_original_fasta
{
  my ($self) = @_;

  my $input_seq_io  = Bio::SeqIO->new( -file => $self->cdhit_input_fasta_file, -format => 'Fasta' );
  my $output_seq_io = Bio::SeqIO->new( -file => ">".$self->cdhit_output_fasta_file, -format => 'Fasta' );
  
  while ( my $input_seq = $input_seq_io->next_seq() ) 
  {
    unless(defined($self->_all_full_cluster_genes->{$input_seq->display_id}))
    {
      $output_seq_io->write_seq($input_seq);
    }
  }
  
  $self->_create_groups_file;
  return $self;
}

sub filter_full_clusters_from_fasta
{
    my ($self) = @_;
 
    while ( my $input_seq = $self->_input_seqio->next_seq() ) {
      unless(defined($self->_full_cluster_gene_names->{$input_seq->display_id}))
      {
        $self->_output_seqio->write_seq($input_seq);
      }
    }
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

