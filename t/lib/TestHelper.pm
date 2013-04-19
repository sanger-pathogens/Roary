package TestHelper;
use Moose::Role;
use Test::Most;
use File::Slurp;


sub mock_execute_script_and_check_output {
    my ( $script_name, $scripts_and_expected_files ) = @_;
    
    open OLDOUT, '>&STDOUT';
    open OLDERR, '>&STDERR';
    eval("use $script_name ;");
    my $returned_values = 0;
    {
        #local *STDOUT;
        #open STDOUT, '>/dev/null' or warn "Can't open /dev/null: $!";
        #local *STDERR;
        #open STDERR, '>/dev/null' or warn "Can't open /dev/null: $!";

        for my $script_parameters ( sort keys %$scripts_and_expected_files ) {
            my $full_script = $script_parameters;
            my @input_args = split( " ", $full_script );

            my $cmd = "$script_name->new(args => \\\@input_args, script_name => '$script_name')->run;";
            eval($cmd); warn $@ if $@;
            my $actual_output_file_name = $scripts_and_expected_files->{$script_parameters}->[0];
            my $expected_output_file_name = $scripts_and_expected_files->{$script_parameters}->[1];
            ok(-e $actual_output_file_name, "Actual output file exists $actual_output_file_name");
            is(read_file($actual_output_file_name), read_file($expected_output_file_name), "Actual and expected output match for '$script_parameters'");
            #unlink($actual_output_file_name);
        }
        #close STDOUT;
        #close STDERR;
    }

    # Restore stdout.
    open STDOUT, '>&OLDOUT' or die "Can't restore stdout: $!";
    open STDERR, '>&OLDERR' or die "Can't restore stderr: $!";

    # Avoid leaks by closing the independent copies.
    close OLDOUT or die "Can't close OLDOUT: $!";
    close OLDERR or die "Can't close OLDERR: $!";
}

no Moose;
1;

