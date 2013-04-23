package Bio::PanGenome::InflateClusters;

# ABSTRACT: Take the clusters file from cd-hit and use it to inflate the output of MCL

=head1 SYNOPSIS

Take the clusters file from cd-hit and use it to inflate the output of MCL
   use Bio::PanGenome::InflateClusters;
   
   my $obj = Bio::PanGenome::InflateClusters->new(
     clusters_filename  => 'example.clstr',
     mcl_filename       => 'example.mcl',
     output_file        => 'example.output'
   );
   $obj->inflate;

=cut

use Moose;
use Bio::PanGenome::Exceptions;

has 'clusters_filename' => ( is => 'ro', isa => 'Str', required => 1 );
has 'mcl_filename'      => ( is => 'ro', isa => 'Str', required => 1 );
has 'output_file'       => ( is => 'ro', isa => 'Str', default  => 'inflated_results' );

has '_clusters_fh'      => ( is => 'ro',lazy => 1, builder => '_build__clusters_fh' );
has '_mcl_fh'           => ( is => 'ro',lazy => 1, builder => '_build__mcl_fh' );
has '_output_fh'        => ( is => 'ro',lazy => 1, builder => '_build__output_fh' );
has '_clustered_genes'  => ( is => 'ro',lazy => 1, builder => '_build__clustered_genes' );

sub _build__clustered_genes
{
  my($self) = @_;
  my $fh = $self->_clusters_fh;
  my %clustered_genes ;
  my $current_gene_name;
  while(<$fh>)
  {
    my $line = $_;
    next if($line =~ /^>/);
    #>Cluster 5
    #0	4201aa, >6630_4#9_00008... *
    #1	4201aa, >6631_1#23_00379... at 100.00%        
    if($line =~ /[\d]+\t[\w]+, >(.+)\.\.\. (.+)$/)
    {
      my $gene_name = $1;
      my $identity  = $2;
      
      if($identity eq '*')
      {
        $current_gene_name = $gene_name;
      }
      else
      {
        push(@{$clustered_genes{$current_gene_name}}, $gene_name);
      }
    }
  }
  return \%clustered_genes;
}

sub _build__output_fh
{
  my($self) = @_;
  open(my $fh, '>', $self->output_file) or Bio::PanGenome::Exceptions::CouldntWriteToFile->throw( error => 'Cant write to file: ' . $self->output_file );
  return $fh;
}

sub _build__mcl_fh
{
   my($self) = @_;
   open(my $fh, $self->mcl_filename) or Bio::PanGenome::Exceptions::FileNotFound->throw( error => 'Cant open file: ' . $self->mcl_filename );
   return $fh;
}

sub _build__clusters_fh
{
  my($self) = @_;
  open(my $fh, $self->clusters_filename) or Bio::PanGenome::Exceptions::FileNotFound->throw( error => 'Cant open file: ' . $self->clusters_filename );
  return $fh;
}

sub _inflate_line
{
   my($self, $line) = @_;
   my @inflated_genes;
   chomp($line);
   my @gene_names = split(/ /, $line);
   for my $gene_name (@gene_names)
   {
     push(@inflated_genes, $self->_inflate_gene($gene_name));
   }
   return join(' ',@inflated_genes);
}

sub _inflate_gene
{
   my($self, $gene_name) = @_;
   my $inflated_gene = $gene_name;
   if(defined($self->_clustered_genes->{$gene_name}))
   {
     $inflated_gene = $inflated_gene.' '. join(' ',@{$self->_clustered_genes->{$gene_name}});
   }
   return $inflated_gene;
}

sub inflate
{
  my($self) = @_;
  my $mcl_fh = $self->_mcl_fh;
  while(<$mcl_fh>)
  {
    my $line = $_;
    print { $self->_output_fh } $self->_inflate_line($line) . "\n";
  }
  close($self->_output_fh);
  1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
