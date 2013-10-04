package Bio::PanGenome::AnnotateGroups;

# ABSTRACT: Take in a group file and assosiated GFF files for the isolates and update the group name to the gene name

=head1 SYNOPSIS

Take in a group file and assosiated GFF files for the isolates and update the group name to the gene name
   use Bio::PanGenome::AnnotateGroups;
   
   my $obj = Bio::PanGenome::AnnotateGroups->new(
     gff_files   => ['abc.gff','efg.gff'],
     output_filename   => 'example_output.fa',
     groups_filename => 'groupsfile',
   );
   $obj->reannotate;

=cut

use Moose;
use Bio::PanGenome::Exceptions;
use Bio::PanGenome::GeneNamesFromGFF;

has 'gff_files'          => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'output_filename'    => ( is => 'ro', isa => 'Str',      default  => 'reannotated_groups_file' );
has 'groups_filename'    => ( is => 'ro', isa => 'Str',      required => 1 );
has '_ids_to_gene_names' => ( is => 'ro', isa => 'HashRef',  lazy     => 1, builder => '_build__ids_to_gene_names' );
has '_ids_to_product' => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has '_groups_to_id_names' => ( is => 'ro', isa => 'HashRef', lazy => 1, builder => '_builder__groups_to_id_names' );
has '_output_fh' => ( is => 'ro', lazy => 1, builder => '_build__output_fh' );
has '_groups_to_consensus_gene_names' =>
  ( is => 'rw', isa => 'HashRef', lazy => 1, builder => '_build__groups_to_consensus_gene_names' );
has '_filtered_gff_files' => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build__filtered_gff_files' );
has '_number_of_files'    => ( is => 'ro', isa => 'Int',      lazy => 1, builder => '_build__number_of_files' );
has '_ids_to_groups'      => ( is => 'rw', isa => 'HashRef',  lazy => 1, builder => '_builder__ids_to_groups' );

has '_group_counter'         => ( is => 'rw', isa => 'Int',  lazy => 1, builder => '_builder__group_counter' );
has '_group_default_prefix'  => ( is => 'rw', isa => 'Str',  default => 'group_' );


sub BUILD {
    my ($self) = @_;
    $self->_ids_to_gene_names;
}

sub _builder__group_counter
{
  my ($self) = @_;
  my $prefix = $self->_group_default_prefix;
  my $highest_group = 0;
  for my $group (@{$self->_groups})
  {
    if( $group =~/$prefix([\d]+)$/)
    {
      my $group_id = $1;
      if($group_id > $highest_group)
      {
        $highest_group = $group_id;
      }
    }
  }
  return $highest_group+1;
}

sub _generate__ids_to_groups {
    my ($self) = @_;
    my %ids_to_groups;

    for my $group ( keys %{ $self->_groups_to_id_names } ) {
        for my $id_name ( @{$self->_groups_to_id_names->{$group}} ) {
            $ids_to_groups{$id_name} = $group;
        }
    }
    return \%ids_to_groups;
}

sub _builder__ids_to_groups {
    my ($self) = @_;
    return $self->_generate__ids_to_groups;
}

sub _build__output_fh {
    my ($self) = @_;
    open( my $fh, '>', $self->output_filename )
      or Bio::PanGenome::Exceptions::CouldntWriteToFile->throw(
        error => "Couldnt write output file:" . $self->output_filename );
    return $fh;
}

sub _build__filtered_gff_files {
    my ($self) = @_;
    my @gff_files = grep( /\.gff$/, @{ $self->gff_files } );
    return \@gff_files;
}

sub _build__ids_to_gene_names {
    my ($self) = @_;
    my %ids_to_gene_names;
    my %ids_to_product;
    for my $filename ( @{ $self->_filtered_gff_files } ) {
        my $gene_names_from_gff = Bio::PanGenome::GeneNamesFromGFF->new( gff_file => $filename );
        my %id_to_gene_lookup = %{ $gene_names_from_gff->ids_to_gene_name };
        @ids_to_gene_names{ keys %id_to_gene_lookup } = values %id_to_gene_lookup;

        my %id_to_product_lookup = %{ $gene_names_from_gff->ids_to_product };
        @ids_to_product{ keys %id_to_product_lookup } = values %id_to_product_lookup;
    }
    $self->_ids_to_product( \%ids_to_product );

    return \%ids_to_gene_names;
}

sub _builder__groups_to_id_names {
    my ($self) = @_;
    my %groups_to_id_names;

    open( my $fh, $self->groups_filename )
      or Bio::PanGenome::Exceptions::FileNotFound->throw( error => "Group file not found:" . $self->groups_filename );
    while (<$fh>) {
        chomp;
        my $line = $_;
        if ( $line =~ /^(.+): (.+)$/ ) {
            my $group_name = $1;
            my $genes      = $2;
            my @elements   = split( /[\s\t]+/, $genes );
            $groups_to_id_names{$group_name} = \@elements;
        }
    }
    return \%groups_to_id_names;
}


sub _groups
{
  my ( $self) = @_;
  my @groups = keys %{$self->_groups_to_id_names};
  return \@groups;
}

sub _ids_grouped_by_gene_name_for_group {
    my ( $self, $group_name ) = @_;
    my %gene_name_freq;
    for my $id_name ( @{ $self->_groups_to_id_names->{$group_name} } ) {
        if ( defined( $self->_ids_to_gene_names->{$id_name} ) && $self->_ids_to_gene_names->{$id_name} ne "" ) {
            push( @{ $gene_name_freq{ $self->_ids_to_gene_names->{$id_name} } }, $id_name );
        }
    }
    return \%gene_name_freq;
}

sub _consensus_gene_name_for_group {
    my ( $self, $group_name ) = @_;
    my $gene_name_freq = $self->_ids_grouped_by_gene_name_for_group($group_name);

    my @sorted_gene_names = sort { @{ $gene_name_freq->{$b} } <=> @{ $gene_name_freq->{$a} } } keys %{$gene_name_freq};
    if ( @sorted_gene_names > 0 ) {
        return shift(@sorted_gene_names);
    }
    else {
        return $group_name;
    }
}

sub _generate_groups_to_consensus_gene_names {
    my ($self) = @_;
    my %groups_to_gene_names;
    my %gene_name_freq;

    for my $group_name ( keys %{ $self->_groups_to_id_names } ) {
        my $consensus_gene_name = $self->_consensus_gene_name_for_group($group_name);

        if ( defined( $gene_name_freq{$consensus_gene_name} ) ) {
            $groups_to_gene_names{$group_name} = $group_name;
        }
        else {
            $groups_to_gene_names{$group_name} = $consensus_gene_name;
        }
        $gene_name_freq{$consensus_gene_name}++;
    }
    return \%groups_to_gene_names;
}

sub _build__groups_to_consensus_gene_names {
    my ($self) = @_;
    return $self->_generate_groups_to_consensus_gene_names;
}

sub _build__number_of_files {
    my ($self) = @_;
    return @{ $self->gff_files };
}

sub _split_groups {
    my ($self) = @_;
    my @groups = keys %{ $self->_groups_to_id_names };
    for my $group (@groups) {
        my $size_of_group = @{ $self->_groups_to_id_names->{$group} };
        next if ( $size_of_group <= $self->_number_of_files );
        my $ids_grouped_by_gene_name = $self->_ids_grouped_by_gene_name_for_group($group);

        for my $gene_name ( keys %{$ids_grouped_by_gene_name} ) {
            next if ( ( !defined($gene_name) ) || $gene_name eq '' );
            next if ($group eq $gene_name);
            if ( defined( $self->_groups_to_id_names->{$gene_name} ) )
            {
              if($group ne $gene_name)
              {
                my $new_group_name = $self->_group_default_prefix.$self->_group_counter;
                $self->_groups_to_id_names->{$new_group_name} = $ids_grouped_by_gene_name->{$gene_name};
                $self->_remove_ids_from_group($ids_grouped_by_gene_name->{$gene_name}, $group);
              }
              
            }
            else
            {
              $self->_groups_to_id_names->{$gene_name} = $ids_grouped_by_gene_name->{$gene_name};
              $self->_remove_ids_from_group($ids_grouped_by_gene_name->{$gene_name},$group);
          }
        }
    }

    $self->_groups_to_consensus_gene_names( $self->_generate_groups_to_consensus_gene_names );
    $self->_ids_to_groups( $self->_generate__ids_to_groups );
}

sub _remove_ids_from_group
{
  my ($self,$ids_to_remove,$group) = @_;
  
  my @remaining_ids =
    grep { not $_ ~~ @{ $ids_to_remove } } @{ $self->_groups_to_id_names->{$group} };
  $self->_groups_to_id_names->{$group} = \@remaining_ids;
  if ( @{ $self->_groups_to_id_names->{$group} } == 0 ) {
      delete( $self->_groups_to_id_names->{$group} );
  }
}

sub reannotate {
    my ($self) = @_;

    $self->_split_groups;

    my %groups_to_id_names = %{ $self->_groups_to_id_names };
    for
      my $group_name ( sort { @{ $groups_to_id_names{$b} } <=> @{ $groups_to_id_names{$a} } } keys %groups_to_id_names )
    {
        my $consensus_gene_name = $self->_groups_to_consensus_gene_names->{$group_name};
        print { $self->_output_fh } $consensus_gene_name . ": "
          . join( "\t", @{ $self->_groups_to_id_names->{$group_name} } ) . "\n";
    }
    close( $self->_output_fh );
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
