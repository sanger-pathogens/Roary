package Bio::Roary::SplitGroups;

# ABSTRACT: split groups

=head1 SYNOPSIS

	use Bio::Roary::SplitGroups;

=cut

use Moose;
use Bio::Roary::AnalyseGroups;
use File::Path qw(make_path remove_tree);
use File::Copy qw(move);
use File::Temp;
use File::Basename;
use File::Slurper 'read_lines';
use Cwd;


has 'groupfile'   => ( is => 'ro', isa => 'Str',      required => 1 );
has 'fasta_files' => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'outfile'     => ( is => 'ro', isa => 'Str',      required => 1 );
has 'iterations'  => ( is => 'ro', isa => 'Int',      default  => 5 );
has 'dont_delete' => ( is => 'ro', isa => 'Bool',     default  => 0 );

has '_neighbourhood_size' => ( is => 'ro', isa => 'Int', default => 5 );

has '_group_filelist'  => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1 );
has '_tmp_dir_object' => ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );
has '_tmp_dir'        => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__tmp_dir' );

has '_analyse_groups_obj' => ( is => 'ro', lazy_build => 1 );
has '_genes_to_files'     => ( is => 'ro', lazy_build => 1 );
has '_genes_to_groups'    => ( is => 'rw', isa => 'HashRef' );

has '_first_gene_of_group_which_doesnt_have_paralogs'    => ( is => 'rw', isa => 'HashRef', default => sub {{}} );

has '_genes_to_neighbourhood' => ( is => 'rw', isa => 'HashRef', lazy => 1, builder => '_build__genes_to_neighbourhood' );


has '_gene_files_temp_dir_obj' =>
  ( is => 'ro', isa => 'File::Temp::Dir', default => sub { File::Temp->newdir( DIR => getcwd, CLEANUP => 1 ); } );


has '_do_sorting' => ( is => 'rw', isa => 'Bool', default => 0 ); # set to 1 for testing only

sub _build__tmp_dir {
    my ($self) = @_;
    return $self->_tmp_dir_object->dirname();
}

sub _build__analyse_groups_obj {
	my ( $self ) = @_;
	
	return Bio::Roary::AnalyseGroups->new(
		fasta_files     => $self->fasta_files,
		groups_filename => $self->groupfile
	);
}

sub _build__genes_to_files {
	my ( $self ) = @_;
	return $self->_analyse_groups_obj->_genes_to_file;
}

sub _build__group_filelist {
	my ( $self ) = @_;
	my $tmp = $self->_tmp_dir;

	my @filelist = ( $self->groupfile );
	for my $i ( 1..($self->iterations - 1) ){
		push( @filelist, "$tmp/group_$i" );
	}
	push( @filelist, $self->outfile );

	return \@filelist;
}

sub _build__genes_to_neighbourhood
{
  my ( $self ) = @_;
  my %genes_to_neighbourhood;
  for my $fasta_file( @{$self->fasta_files})
  {
	my ( $filename, $directories, $suffix ) = fileparse( $fasta_file, qr/\.[^.]*/ );
  	system('grep \> '.$fasta_file.'| sed  \'s/>//\' >'.$self->_gene_files_temp_dir_obj."/".$filename.$suffix ) ;
	
	my @genes = read_lines($self->_gene_files_temp_dir_obj."/".$filename.$suffix );
	
	for(my $i =0; $i< @genes; $i++)
	{
		for(my $offset = 1; $offset <= $self->_neighbourhood_size; $offset++)
		{
			if($i -$offset >= 0)
			{
			   push(@{$genes_to_neighbourhood{$genes[$i]}}, $genes[$i - $offset ]);
		    }
			if($i +$offset <@genes)
			{
			   push(@{$genes_to_neighbourhood{$genes[$i]}}, $genes[$i + $offset ]);
		    }
		}
	}
  }
  return \%genes_to_neighbourhood;
}

sub split_groups {
	my ( $self ) = @_;

	# iteratively
	for my $x ( 0..($self->iterations - 1) ){
		my ( $in_groups, $out_groups ) = $self->_get_files_for_iteration( $x ); 

		# read in groups, check paralogs and split
		my @newgroups;
		my $any_paralogs = 0;
		$self->_set_genes_to_groups( $in_groups );
		open( my $group_handle, '<', $in_groups );
		while( my $line = <$group_handle> ){
			my @group = split( /\s+/, $line );

			if($self->_first_gene_of_group_which_doesnt_have_paralogs->{$group[0]})
			{
				push( @newgroups, \@group );
			}
			elsif(@group == 1)
			{
				$self->_first_gene_of_group_which_doesnt_have_paralogs->{$group[0]}++;
				push( @newgroups, \@group );
			}
			elsif( $self->_contains_paralogs( \@group ) ){
				my @true_orthologs = @{ $self->_true_orthologs( \@group ) };
				push( @newgroups,  @true_orthologs);
				$any_paralogs = 1;
			}
			else {
				$self->_first_gene_of_group_which_doesnt_have_paralogs->{$group[0]}++;
				push( @newgroups, \@group );
			}
		}
		close( $group_handle );

		# check if next iteration required, move output if not
		unless ($any_paralogs){
			move $in_groups, $self->outfile; # input file will be the same as new output file if no splitting has been performed
			last;
		}

		# write split groups to file
		open( my $outfile_handle, '>', $out_groups );
		for my $g ( @newgroups ) {
			my $group_str = join( "\t", @{ $g } ) . "\n";
			print $outfile_handle $group_str;
		}
		close( $outfile_handle );
	}
}

sub _set_genes_to_groups {
	my ( $self, $groupfile ) = @_;

	my %genes2groups;
	my $c = 0;
	open( my $gfh, '<', $groupfile );
	while( my $line = <$gfh> ){
		chomp $line;
		my @genes = split( /\s+/, $line );
		for my $g ( @genes ){
			$genes2groups{$g} = $c;
		}
		$c++;
	}
    close($gfh);
	$self->_genes_to_groups( \%genes2groups );
}

sub _update_genes_to_groups {
	my ( $self, $groups ) = @_;

	my %genes2groups = %{ $self->_genes_to_groups };
	my $c = 1;
	for my $g ( @{ $groups } ){
		for my $h ( @{ $g } ){
			$genes2groups{$h} .= ".$c";
		}
		$c++;
	}

	$self->_genes_to_groups( \%genes2groups );
}

sub _get_files_for_iteration {
	my ( $self, $n ) = @_;
	my @filelist = @{ $self->_group_filelist };
	return ( $filelist[$n], $filelist[$n+1] );
}

sub _contains_paralogs {
	my ( $self, $group ) = @_;

	return 1 if defined $self->_find_paralogs( $group );
	return 0;
}

sub _find_paralogs {
	my ( $self, $group ) = @_;

	my %occ;
	for my $gene ( @{ $group } ){
		my $gene_file = $self->_genes_to_files->{ $gene };
		push( @{ $occ{$gene_file} }, $gene );
	}

	# pick the smallest number of paralogs
	my $smallest_number = 1000000;
	my $smallest_group;
	for my $v ( values %occ ){
		my $v_len = scalar( @{$v} );
		if ( $v_len < $smallest_number && $v_len > 1 ){
			$smallest_number = $v_len;
			$smallest_group  = $v;
		}
	}
	return $smallest_group if ( defined $smallest_group );

	return undef;
}

sub _true_orthologs {
	my ( $self, $group ) = @_;

	# first, create CGN hash for group
	my %cgns;
	for my $g ( @{ $group } ){
		$cgns{$g} = $self->_parse_gene_neighbourhood( $g );
	}

	# finding paralogs in the group
	my @paralogs = @{ $self->_find_paralogs( $group ) };
	my @paralog_cgns_groups;
	for my $p ( @paralogs ){
		my %paralog_groups ;
		for my $paralog_gene (@{$cgns{$p}})
		{
			my $gene_paralog_group = $self->_genes_to_groups->{$paralog_gene};
			next unless( defined($gene_paralog_group));
			$paralog_groups{$self->_genes_to_groups->{$paralog_gene}}++;
		}
		push( @paralog_cgns_groups, \%paralog_groups );
	}

	# create data structure to hold new groups
	my @new_groups;
	for my $p ( @paralogs ){
		push( @new_groups, [ $p ] );
	}
	push( @new_groups, [] ); # extra "leftovers" array to gather genes that don't share CGN with anything

	# cluster other members of the group to their closest match
	for my $g ( @{ $group } ){
		next if ( grep {$_ eq $g} @paralogs );
		my $closest = $self->_closest_cgn( $cgns{$g}, \@paralog_cgns_groups );
		push( @{ $new_groups[$closest] }, $g );
	}

	# check for "leftovers", remove if absent
	my $last = pop @new_groups;
	push( @new_groups, $last ) if ( @$last > 0 );

	# sort
	if ( $self->_do_sorting ){
		my @sorted_new_groups;
		for my $gr ( @new_groups ){
			my @s_gr = sort @{ $gr };
			push( @sorted_new_groups, \@s_gr );
		}
		return \@sorted_new_groups;
	}

	return \@new_groups;
}

sub _closest_cgn {
	my ( $self, $cgn, $p_cgns ) = @_;

	my @paralog_cgns = @{ $p_cgns };
	my $best_score = 0;
	my $bs_index = -1; # return -1 to add to "leftovers" array if no better score is found
	for my $i ( 0..$#paralog_cgns ){
		my $p_cgn = $paralog_cgns[$i];
		my $score = $self->_shared_cgn_score( $cgn, $p_cgn );
		if ( $score > $best_score ){
			$best_score = $score;
			$bs_index   = $i;
		}
	}
	return $bs_index;
}

sub _shared_cgn_score {
	my ( $self, $cgn1, $cgn2 ) = @_;

	my $total_shared = 0;
	for my $i ( @{ $cgn1 } ){
		my $input_group = $self->_genes_to_groups->{$i};
		next unless(defined($input_group));
		$total_shared++ if($cgn2->{$input_group});
	}
	if( (scalar @{ $cgn1 }) == 0)
	{
	  return 0;
  }
	my $score = $total_shared/scalar @{ $cgn1 };
	return $score;
}

sub _parse_gene_neighbourhood {
	my ( $self, $gene_id ) = @_;

    return $self->_genes_to_neighbourhood->{$gene_id };

}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
