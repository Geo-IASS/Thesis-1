#!/usr/bin/perl

################################################################################
#
# Script to convert Matlab profiler output into CSV format. Processes multiple 
# datasets from multiple executions of the Matlab script.
# 
# Input:	Base directory where the profiler output is found. Should contain 
#			subdirectories named after the data sets that the data pertains to.
#			Each data set subdirectory should contain a single subdirectory for 
#			each iteration of the Matlab code.
# Output:	Profiler data in CSV format
#
################################################################################

use strict;
use warnings;

use HTML::TableExtract;
use File::Util;
use File::Spec;

use constant USEFUL_HTML_FILE => "file0.html";
use constant OUTPUT_HEADER => "Data set,Iteration,Function Name,Calls,Total Time,Self Time\n";

# The argument should be the base directory for the profiling data
my $base_dir = $ARGV[0];

# File::Util used to traverse directories
my $fu = File::Util->new;

# Get data sets from subdirectories below base directory
my @datasets = $fu->list_dir($base_dir, '--dirs-only', '--no-fsdots', '--with-paths');

# Print header of output
print(OUTPUT_HEADER);

# For calculating average values across all data sets
my %alldata_calls = ();
my %alldata_total_time = ();
my %alldata_self_time = ();
my $alldata_iterations = 0;

# Loop through each data set
for my $dataset (@datasets) {
	# String to appear in output data (note: strip out directory name)
	my $dataset_string = $dataset;
	$dataset_string =~ s/\/.*\///g;
	
	# Get dataset iterations from subdirectories below base directory
	my @dataset_iterations = $fu->list_dir($dataset, '--dirs-only', '--no-fsdots', '--with-paths');
	
	# For calculating average values across this data set
	my %thisdata_calls = ();
	my %thisdata_total_time = ();
	my %thisdata_self_time = ();
	my $thisdata_iterations = 0;
	
	# Loop through each iteration subdirectory
	for my $iteration (@dataset_iterations) {	
		# String to appear in output data (note: strip out directory name)
		my $iteration_string = $iteration;
		$iteration_string =~ s/\/.*\///g;
	
		# Retrieve the input HTML file
		my $html_table_extract = HTML::TableExtract->new();
		my $useful_html_file = File::Spec->catfile($iteration, USEFUL_HTML_FILE);
		$html_table_extract->parse_file($useful_html_file);

		# Loop through each table in the HTML file (note: should only be one)
		foreach my $table ($html_table_extract->tables()) {
			# We have seen another iteration
			$thisdata_iterations++;
			$alldata_iterations++;
		
			# Get table rows
			my @data_rows = $table->rows();

			# Remove header information from data
			splice(@data_rows, 0, 1);

			# Output the data, looping through each row
			foreach my $row (@data_rows) {
				my $function_name = @$row[0];
				
				my $calls = @$row[1];
				$thisdata_calls{$function_name} += $calls;
				$alldata_calls{$function_name} += $calls;
				
				my $total_time = @$row[2];
				$total_time =~ s/\s*s//;
				$thisdata_total_time{$function_name} += $total_time;
				$alldata_total_time{$function_name} += $total_time;
				
				my $self_time = @$row[3];
				$self_time =~ s/\s*s//;
				$thisdata_self_time{$function_name} += $self_time;
				$alldata_self_time{$function_name} += $self_time;
	
				# Output the data
				print("\"$dataset_string\",\"$iteration_string\",\"$function_name\",$calls,$total_time,$self_time\n");
			}
		}
	}
	
	# Output averages over this data set
	foreach my $function (keys %thisdata_calls) {
		my $calls_average = $thisdata_calls{$function} / $thisdata_iterations;
		my $total_time_average = $thisdata_total_time{$function} / $thisdata_iterations;
		my $self_time_average = $thisdata_self_time{$function} / $thisdata_iterations;
	
		print("\"$dataset_string\",\"average\",\"$function\",$calls_average,$total_time_average,$self_time_average\n");
	}
}

# Output averages over all data sets
foreach my $function (keys %alldata_calls) {
	my $calls_average = $alldata_calls{$function} / $alldata_iterations;
	my $total_time_average = $alldata_total_time{$function} / $alldata_iterations;
	my $self_time_average = $alldata_self_time{$function} / $alldata_iterations;

	print("\"average\",\"average\",\"$function\",$calls_average,$total_time_average,$self_time_average\n");
}
