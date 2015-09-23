#!/usr/bin/env perl

package Bio::Roary::Main::ExtractProteomeFromGFF;

# ABSTRACT: Take in GFF files and output the proteome
# PODNAME: extract_proteome_from_gff

=head1 SYNOPSIS

Take in GFF files and output the proteome

=cut

use Cwd qw(abs_path); 
BEGIN { unshift( @INC, abs_path('./lib') ) }
BEGIN { unshift( @INC, abs_path('./t/lib') ) }
use Bio::Roary::CommandLine::ExtractProteomeFromGff;

Bio::Roary::CommandLine::ExtractProteomeFromGff->new(args => \@ARGV, script_name => $0)->run;
