#!/usr/bin/perl

use strict;
use warnings;

use Cwd 'abs_path';
use File::Basename;

use FindBin;
use lib $FindBin::Bin . '/../../../../scripts';
require 'util.pl';

#===============================================================================
# Configuration
#===============================================================================
my $DATA_FILE = abs_path(dirname($0)).'/../../../../data/profiling/matlab.csv';
my $THIS_DIR = 'appendix/plots/matlab';

use constant OTHER_FUNCTION => '__other__';
use constant OTHER_NAME     => 'Other';
use constant THRESHOLD      => '0.03';
use constant PROFILE        => 'matlab_unsorted_inline';
my $OTHER_NAME = OTHER_NAME;

use constant COL_PROFILE      => 0;
use constant COL_DATASET      => 1;
use constant COL_ITERATION    => 2;
use constant COL_FUNCTION     => 3;
use constant COL_CALLS        => 4;
use constant COL_CALLSREL     => 5;
use constant COL_TOTALTIME    => 6;
use constant COL_TOTALTIMEREL => 7;
use constant COL_SELFTIME     => 8;
use constant COL_SELFTIMEREL  => 9;
#-------------------------------------------------------------------------------

#===============================================================================
# Function name mapping
#===============================================================================
my %function_map = (
    '...er_Pruning_Block_MATLAB_SORTED_INLINE' => 'TopN_Outlier_Pruning_Block',
    '..._Pruning_Block_MATLAB_UNSORTED_INLINE' => 'TopN_Outlier_Pruning_Block',
    'TopN_Outlier_Pruning_Block_C_NO_BLOCKING' => 'TopN_Outlier_Pruning_Block',
    'TopN_Outlier_Pruning_Block_C_SORTED'      => 'TopN_Outlier_Pruning_Block',
    'TopN_Outlier_Pruning_Block_C_UNSORTED'    => 'TopN_Outlier_Pruning_Block',
    'commute_distance_anomaly_profiling'       => 'commute_distance_anomaly'
);
sub format_name($) {
    my $function = $_[0];
    $function =~ s/.*\///;
    $function =~ s/.*>//;
    $function =~ s/\s*(MEX-file)//;
    $function =~ s/\s*(Java method)//;
    $function =~ s/()//;
    
    my $OTHER_FUNCTION = OTHER_FUNCTION;
    if ($function =~ m/$OTHER_FUNCTION/) {
        $function = OTHER_NAME;
    }
    
    if (exists $function_map{$function}) {
        $function = $function_map{$function};
    }
    
    return $function;
}

my %default_colours = (
    'TopN_Outlier_Pruning_Block'    => 'blue!60',
    'pcg'                           => 'cyan!60',
    'hggetbehavior'                 => 'yellow!60',
    'isprop'                        => 'orange!60',
    'localPeek'                     => 'red!60',
    'drawGraph'                     => 'blue!60!cyan!60',
    'knn_components_sparse'         => 'cyan!60!yellow!60',
    'prepare'                       => 'red!60!cyan!60',
    'kdtree_k_nearest_neighbors'    => 'red!60!blue!60',
    '@(b)mx_d_preconditioner(sH,b)' => 'orange!60!cyan!60',
    'iterapp'                       => 'green!60',
    'mx_d_preconditioner'           => 'magenta!60',
    'princomp'                      => 'purple!60',
    $OTHER_NAME                     => 'white!60'
);

my @colours = (
    'blue!60',
    'cyan!60',
    'yellow!60',
    'orange!60',
    'red!60',
    'blue!60!cyan!60',
    'cyan!60!yellow!60',
    'red!60!cyan!60',
    'red!60!blue!60',
    'orange!60!cyan!60',
    'green!60',
    'magenta!60',
    'black!60',
    'gray!60',
    'white!60',
    'brown!60',
    'lime!60',
    'olive!60',
    'pink!60',
    'purple!60',
    'teal!60',
    'violet!60'
);
sub get_colour($) {
    if (scalar(@colours) <= 0) {
        die('No more available colours');
    }
    
    my $colour;
    if (exists $default_colours{format_name($_[0])}) {
        my $requested_colour = $default_colours{format_name($_[0])};
        
        for (my $i = 0; $i < scalar(@colours); $i++) {
            $colour = shift(@colours);
            if ($colour ne $requested_colour) {
                push(@colours, $colour);
            } else {
                $i++;
            }
        }
        
        return $requested_colour;
    } else {
        $colour = shift(@colours);
        push(@colours, $colour);
        return $colour;
    }
}

sub format_number($) {
    return sprintf("%0.2f", $_[0]);
}
#-------------------------------------------------------------------------------

# Make sure an output file was specified
scalar(@ARGV) >= 1 || die('No output file specified!');
my $output_file = $ARGV[0];

# Parse the data
my %data = ();
my %function_colours = ();
open(FILE, "<$DATA_FILE") || die("Cannot open file: $DATA_FILE");
my $in_header = 1;
for (<FILE>) {
    # Skip the header
    if ($in_header) {
        $in_header = 0;
        next;
    }
    
    my @columns       = csv_get_fields($_);
    my $profile       = $columns[COL_PROFILE];
    my $dataset       = $columns[COL_DATASET];
    my $iteration     = $columns[COL_ITERATION];
    my $function      = $columns[COL_FUNCTION];
    my $totaltime_rel = $columns[COL_TOTALTIMEREL];
    my $selftime_rel  = $columns[COL_SELFTIMEREL];
    
    # If this function is fairly small, bundle it with other small functions
    if ($selftime_rel < THRESHOLD) {
        $function = OTHER_FUNCTION;
    }
    
    if ($iteration eq 'average') {
        if (!exists $data{$dataset}) {
            $data{$dataset} = ();
        }
        if (!exists $data{$dataset}{$profile}) {
            $data{$dataset}{$profile} = ();
        }
        if (!exists $data{$dataset}{$profile}{$function}) {
            $data{$dataset}{$profile}{$function} = 0;
        }
        if (!exists $function_colours{$function}) {
            $function_colours{$function} = get_colour($function);
        }
        
        $data{$dataset}{$profile}{$function} += $selftime_rel;
    }
}
close(FILE);

# Write to output file
open(TEX, ">$output_file") or die("Cannot open file: $output_file");

if (basename($0) =~ m/all_datasets.tex.pl/) {
    for my $dataset (keys %data) {
        print TEX "\\input{$THIS_DIR/$dataset}\n"
    }
} else { # we assume that the output file relates to a data set
    my $the_dataset = basename($0, ".tex.pl");
    my $the_dataset_clean = latex_escape($the_dataset);
    my $the_profile = PROFILE;
    my @output = (); # buffered output
    
    # Colours
    my @the_colours = ();
    for my $function (keys %{$data{$the_dataset}{$the_profile}}) {
        push(@the_colours, $function_colours{$function});
    }
    
    my $colour_string = join(',', @the_colours);
    print TEX <<END_OF_TEX;
\\begin{figure}[H]
    \\centering
    \\begin{tikzpicture}
	    \\pie[text=legend, color={$colour_string}]{
END_OF_TEX
    
    # Data
    for my $function (keys %{$data{$the_dataset}{$the_profile}}) {
        my $proportion = 100 * $data{$the_dataset}{$the_profile}{$function};
        $proportion = format_number($proportion);
        my $function = format_name($function);
        $function = latex_escape($function);
        
        push(@output, "$proportion/{$function}");
    }
    
    print TEX join(",\n", @output);
    print TEX <<END_OF_TEX;
        
	    }
    \\end{tikzpicture}
	\\caption{Comparison of function self time for $the_dataset_clean data set}
	\\label{fig:matlabProfiling:$the_dataset}
\\end{figure}
END_OF_TEX
}

close(TEX);
