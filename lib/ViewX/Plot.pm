package ViewX::Plot;

use strict;
use warnings;
use Chart::Gnuplot;
use Smart::Args;
use Furl;
use JSON;
use Time::Piece;

my $API_KEY = "hogehoge";

sub plot {
    args
        my $class,
        my $drivename,
        my $filename,
        my $hostid;

    my $furl = Furl->new(
        headers => [
            'X-Api-Key' => $API_KEY,
            'Content-Type' => 'aplication/json'
        ],
    );

    my @buff;
    my $now_time = time;
    my $before_time = time - 10368000;

    my $body = $furl->get(
        "https://mackerel.io/api/v0/hosts/$hostid"
    );
    my $metric = JSON::from_json($body->content);
    my $hostname = $metric->{host}{name};

    $body = $furl->get(
        "https://mackerel.io/api/v0/hosts/$hostid/metrics?name=filesystem.$drivename.used&from=$before_time&to=$now_time"
    );

    $metric = JSON::from_json($body->content);

    my $count = 0;
    foreach (@{$metric->{metrics}}) {
        $buff[$count]->[0] = $_->{time};
        $buff[$count++]->[1] = $_->{value};
    }

    $body = $furl->get(
        "https://mackerel.io/api/v0/hosts/$hostid/metrics?name=filesystem.$drivename.size&from=$before_time&to=$now_time"
    );

    $metric = JSON::from_json($body->content);

    $count = 0;
    foreach (@{$metric->{metrics}}) {
        $buff[$count++]->[2] = $_->{value};
    }

    my $prefix_str = "TB";
    my $prefix_digit = 1000000000000;
    if($buff[$#buff]->[1]<1000000000000){
        $prefix_str = "GB";
        $prefix_digit = 1000000000;
    }elsif($buff[$#buff]->[1]<1000000000){
        $prefix_str = "MB";
        $prefix_digit = 1000000;
    }

    my @used_x = ();
    my @used_y = ();
    my @capacity_x = ();
    my @capacity_y = ();

    for(@buff){
        my $time = Time::Piece->strptime($_->[0], "%s");
        push (@used_x, $time->ymd);
        push (@used_y, $_->[1]/$prefix_digit);
        push (@capacity_x, $time->ymd);
        push (@capacity_y, $_->[2]/$prefix_digit);
    }

    my $limit = 10;
    my @near = (0,0,0,0);
    my $x;
    my $y;
    for(my $c = 0;$c<$limit;$c++){
        $x = $buff[$#buff - $c]->[0];
        $y = $buff[$#buff - $c]->[1];
        $near[0] += ($x * $y);
        $near[1] += $x;
        $near[2] += $y;
        $near[3] += $x ** 2;
    }
    my $calc_a = ( ($limit*$near[0]) - ($near[1]*$near[2]) )/( ($limit*$near[3]) - $near[1]**2 );
    my $calc_b = ( ($near[3]*$near[2]) - ($near[0]*$near[1]) )/( ($limit*$near[3]) - $near[1]**2 );
    my $answer = sprintf "%d",(($buff[$#buff]->[2])-$calc_b)/$calc_a;
    my $ans_time = Time::Piece->strptime($answer,"%s");
    my $now_time_str = sprintf "%s",Time::Piece->strptime($now_time,"%s")->ymd;
    my $after_time_str = sprintf "%s",$ans_time->ymd;

    my @yosoku_x = ($now_time_str, $after_time_str);
    my @yosoku_y = ($buff[$#buff]->[1]/$prefix_digit, $buff[$#buff]->[2]/$prefix_digit);
    push (@capacity_x, $after_time_str);
    push (@capacity_y, $buff[$#buff]->[2]/$prefix_digit);

    my $chart = Chart::Gnuplot->new(
        output => $filename,
        imagesize => "2, 1.5",
        title => "$hostname($hostid) $drivename $now_time_str (overflow: $after_time_str)",
        legend => {
            position => "bottom",
        },
        xlabel => "Date[yy/mm/dd]",
        ylabel => "capacity[$prefix_str]",

        timeaxis => 'x',
        xtics    => {
            labelfmt => '%y/%m/%d',
        },

    );

    my $used_dataset = Chart::Gnuplot::DataSet->new(
        xdata=>\@used_x,
        ydata=>\@used_y,
        color => '#ff0000',
        style => "lines",
        timefmt => "%Y-%m-%d",
        width => 3,
        title => "used",
    );
    my $yosoku_dataset = Chart::Gnuplot::DataSet->new(
        xdata=>\@yosoku_x,
        ydata=>\@yosoku_y,
        color => '#00ff00',
        style => "lines",
        timefmt => "%Y-%m-%d",
        width => 3,
        title => "used(yosoku)",
    );
    my $capacity_dataset = Chart::Gnuplot::DataSet->new(
        xdata=>\@capacity_x,
        ydata=>\@capacity_y,
        color => '#0000ff',
        style => "lines",
        timefmt => "%Y-%m-%d",
        width => 3,
        title => "capacity",
    );

    $chart->plot2d($used_dataset, $yosoku_dataset, $capacity_dataset);
}

1;
