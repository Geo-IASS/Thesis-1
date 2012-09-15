#!/usr/bin/perl

################################################################################
#
# A utility file with various common functions.
#
################################################################################

#===============================================================================
# Returns the number of days in a given month.
# 0=January, 1=February, ..., 10=November, 11=December
#
# Usage:
#     days_in_month($month_index);
#===============================================================================
sub days_in_month($) {
    $_[0] = $_[0] % 12;
    
    if ($_[0] == 0) {
        return 31;
    } elsif ($_[0] == 1) {
        return 29;
    } elsif ($_[0] == 2) {
        return 31;
    } elsif ($_[0] == 3) {
        return 30;
    } elsif ($_[0] == 4) {
        return 31;
    } elsif ($_[0] == 5) {
        return 30;
    } elsif ($_[0] == 6) {
        return 31;
    } elsif ($_[0] == 7) {
        return 31;
    } elsif ($_[0] == 8) {
        return 30;
    } elsif ($_[0] == 9) {
        return 31;
    } elsif ($_[0] == 10) {
        return 30;
    } elsif ($_[0] == 11) {
        return 31;
    }
}

#===============================================================================
# Escapes special characters for LaTeX
#
# Usage:
#     latex_escape($string)
#===============================================================================
sub latex_escape($) {
    my $string = $_[0];
    $string =~ s/_/\\_/g;
    return $string;
}

# Necessary to "require" this file from other perl scripts.
1;
