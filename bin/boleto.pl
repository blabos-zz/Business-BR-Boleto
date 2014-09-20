#!/usr/bin/env perl

use strict;
use warnings;

use PDF::API2;
use Const::Fast;

const my $mm => 25.4/72;
const my $in => 1/72;
const my $pt => 1;

my $pdf = PDF::API2->new;
my $page = $pdf->page;
$page->mediabox('A4');

my $png = $pdf->image_png('boleto.png');
my $image = $page->gfx;
$image->image($png, 0, 0, 210/$mm, 297/$mm);

$pdf->saveas('boleto.pdf');

# PODNAME: bobby_tables.pl
