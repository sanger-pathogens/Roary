package TestHelper;
use Moose::Role;
use Test::Most;
use File::Slurp;
use Data::Dumper;


sub mock_execute_script_and_check_output {
    my ( $script_name, $scripts_and_expected_files, $columns_to_exclude ) = @_;
    
    system('touch empty_file');
    
    open OLDOUT, '>&STDOUT';
    open OLDERR, '>&STDERR';
    eval("use $script_name ;");
    my $returned_values = 0;
    {
        local *STDOUT;
        open STDOUT, '>/dev/null' or warn "Can't open /dev/null: $!";
        local *STDERR;
        open STDERR, '>/dev/null' or warn "Can't open /dev/null: $!";

        for my $script_parameters ( sort keys %$scripts_and_expected_files ) {
            my $full_script = $script_parameters;
            my @input_args = split( " ", $full_script );

            my $cmd = "$script_name->new(args => \\\@input_args, script_name => '$script_name')->run;";
            eval($cmd); warn $@ if $@;
            
            my $actual_output_file_name = $scripts_and_expected_files->{$script_parameters}->[0];
            my $expected_output_file_name = $scripts_and_expected_files->{$script_parameters}->[1];

            ok(-e $actual_output_file_name, "Actual output file exists $actual_output_file_name  $script_parameters");
            if(defined($columns_to_exclude))
            {
              is(
                 _exclude_variable_columns_from_spreadsheet($actual_output_file_name, $columns_to_exclude ), 
                 _exclude_variable_columns_from_spreadsheet($expected_output_file_name, $columns_to_exclude ), 
                 'Actual and expected match output excluding variable columns'); 
            }
            else
            {
              is(read_file($actual_output_file_name), read_file($expected_output_file_name), "Actual and expected output match for '$script_parameters'");
            }
            unlink($actual_output_file_name);
        }
        close STDOUT;
        close STDERR;
    }

    # Restore stdout.
    open STDOUT, '>&OLDOUT' or die "Can't restore stdout: $!";
    open STDERR, '>&OLDERR' or die "Can't restore stderr: $!";

    # Avoid leaks by closing the independent copies.
    close OLDOUT or die "Can't close OLDOUT: $!";
    close OLDERR or die "Can't close OLDERR: $!";
    unlink('empty_file');
}



sub mock_execute_script_and_check_output_sorted {
    my ( $script_name, $scripts_and_expected_files, $columns_to_exclude ) = @_;
    
    system('touch empty_file');
    
    open OLDOUT, '>&STDOUT';
    open OLDERR, '>&STDERR';
    eval("use $script_name ;");
    my $returned_values = 0;
    {
        local *STDOUT;
        open STDOUT, '>/dev/null' or warn "Can't open /dev/null: $!";
        local *STDERR;
        open STDERR, '>/dev/null' or warn "Can't open /dev/null: $!";

        for my $script_parameters ( sort keys %$scripts_and_expected_files ) {
            my $full_script = $script_parameters;
            my @input_args = split( " ", $full_script );

            my $cmd = "$script_name->new(args => \\\@input_args, script_name => '$script_name')->run;";
            eval($cmd); warn $@ if $@;
            
            my $actual_output_file_name = $scripts_and_expected_files->{$script_parameters}->[0];

            my $expected_output_file_name = $scripts_and_expected_files->{$script_parameters}->[1];
            ok(-e $actual_output_file_name, "Actual output file exists $actual_output_file_name  $script_parameters");
            if(defined($columns_to_exclude))
            {
              my @actual_content_sorted = sort(split(/\n/, _exclude_variable_columns_from_spreadsheet($actual_output_file_name, $columns_to_exclude )));
              my @expected_content_sorted = sort(split(/\n/, _exclude_variable_columns_from_spreadsheet($expected_output_file_name, $columns_to_exclude )));
              is_deeply( \@actual_content_sorted, \@expected_content_sorted, 
                 'Actual and expected match output excluding variable columns'); 
            }
            else
            {
              my @actual_content_sorted = sort(read_file($actual_output_file_name));
              my @expected_content_sorted = sort(read_file($expected_output_file_name));
              is_deeply(\@actual_content_sorted, \@expected_content_sorted, "Actual and expected sorted output match for '$script_parameters'");
            }
            unlink($actual_output_file_name);
        }
        close STDOUT;
        close STDERR;
    }

    # Restore stdout.
    open STDOUT, '>&OLDOUT' or die "Can't restore stdout: $!";
    open STDERR, '>&OLDERR' or die "Can't restore stderr: $!";
    
    # Avoid leaks by closing the independent copies.
    close OLDOUT or die "Can't close OLDOUT: $!";
    close OLDERR or die "Can't close OLDERR: $!";
    unlink('empty_file');
}



sub compare_tab_files_with_variable_coordinates
{
  my ( $actual_file, $expected_file ) = @_;
  ok(-e $actual_file, 'File exists'.  $actual_file);
  
  is(_filter_coordinates_from_string( $actual_file), _filter_coordinates_from_string($expected_file), 'file contents the same for '.$actual_file);
}

sub _filter_coordinates_from_string
{
  my ( $file_name) = @_;
  my $file_contents = read_file($file_name);
  my @lines = split(/\n/,$file_contents);
  my $modified_file_contents = '';
  for my $line (sort @lines)
  {
    next if($line =~ /(variation|misc_feature|feature)/);
    $modified_file_contents .= $line."\n";
  }
  return $modified_file_contents;
}

sub _exclude_variable_columns_from_spreadsheet
{
  my ( $file_name, $columns_to_exclude) = @_;
  my $file_contents = read_file($file_name);
  my @lines = split(/\n/,$file_contents);
  my $modified_file_contents = '';
  
  for(my $i = 0; $i< @lines; $i++)
  {
    my @cells = split(/,/,$lines[$i]);
    
    for my $col_number( @{$columns_to_exclude})
    {
      next unless(defined($cells[$col_number]));
      $cells[$col_number] = '';
    }
    $modified_file_contents .= join(',', @cells). "\n";
  }
  
  return $modified_file_contents;
}


no Moose;
1;

