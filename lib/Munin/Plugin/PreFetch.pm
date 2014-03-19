package Munin::Plugin::PreFetch;
use File::Temp qw(tempfile);
use File::Copy qw(move);
use File::Basename qw(basename);
use Munin::Common::Defaults;

sub autoconf { return; }
sub suggests { return; }
sub snmpconf { return; }

sub config {
    die "Plugin does not provide a config method\n";
}

sub fetch {
    die "Plugin does not provide a fetch method\n";
}

sub dispatch {
    my $class  = shift;
    my $plugin = basename($0);

    my $dir = $ENV{'MUNIN_PLUGSTATE'} || $Munin::Common::Defaults::MUNIN_PLUGSTATE;
    my $prefetch_file = "$dir/prefetch-$plugin";

    if (@ARGV) {
        if    ( $ARGV[0] eq 'config' )   { $class->config(); }
        elsif ( $ARGV[0] eq 'autoconf' ) { $class->autoconf(); }
        elsif ( $ARGV[0] eq 'suggests' ) { $class->suggests(); }
        elsif ( $ARGV[0] eq 'smtpconf' ) { $class->smtpconf(); }
        elsif ( $ARGV[0] eq 'prefetch' ) {
            my ( $fh, $filename ) = tempfile( UNLINK => 1 );
            my $oldfh = select($fh);
            $class->prefetch();
            select($oldfh);
            close($fh);
            move( $filename, $prefetch_file )
              or die "Can't move file to $prefetch_file: $!\n";
        }
    }
    else {
        if ( -e $prefetch_file ) {
            local (@ARGV) = $prefetch_file ;
            print while <>;
        }
        else {
            print "U\n";
        }

    }
}

1;

__END__

=pod

=head1 NAME

Munin::Plugin::PreFetch - Prefetch results for long running munin plugins

=head1 SYNOPSIS

  # in /etc/munin/plugins/fancyplugin
  use parent 'Munin::Plugin::PreFetch';
  sub config {
  	print "... config ... ";
	return;
  }
  sub prefetch {
  	print long_running_call();
	return;	
  }
  __PACKAGE__->dispatch();
  __END__

  $ munin-run fancyplugin prefetch
  $ munin-run fancyplugin

=head1 DESCRIPTION

When using its default values munin will close the connection after
20 seconds without any activity. So if one of your modules take a few
seconds to run, you can easily run into this threshold and get graphs
with gaps in them. Sure, you can manuelly set the timeout to a higher
value, but what about plugins that takes minutes to return results?

With Munin::Plugin::PreFetch you can call your plugin for example via cron. It
will run the necessary code and write it to a temparory file. When the munin
master node connects and tries to fetch the plugin data, the content of this
file will be returned.

You have to provide the function I<config> and I<prefetch> that should
just print to stdout. If your using magic markers, you can optionally
provide the additional functions I<autoconf>, I<suggests> or I<smtpconf>.

=head1 ENVIRONMENT

=over

=item MUNIN_PLUGSTATE

The directory where the prefetched output is saved in. This variable is
automatically set for your when you run your plugin via munin-run.

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2014 Mario Domgoergen

This library is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Mario Domgoergen L<E<lt>mario@domgoergen.comE<gt>>

=cut
