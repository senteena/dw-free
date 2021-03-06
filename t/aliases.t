# t/aliases.t
#
# Tests email alias setting, with and without dashes
#
# Authors:
#
#      Pau Amma <pauamma@dreamwidth.org>
#
# Copyright (c) 2015 by Dreamwidth Studios, LLC.
#
# This program is free software; you may redistribute it and/or modify it under
# the same terms as Perl itself.  For a copy of the license, please reference
# 'perldoc perlartistic' or 'perldoc perlgpl'.
#

use strict;
use warnings;

use Test::More tests => 6;

BEGIN { $LJ::_T_CONFIG = 1; require "$ENV{LJHOME}/cgi-bin/ljlib.pl"; }
use LJ::Test qw( temp_user );

# Usernames generated by temp_user conveniently have an embedded _.
my $u = temp_user();
LJ::update_user( $u, { status => 'A' } );

# Makei sure all users can have a site email alias.
local $LJ::T_HAS_ALL_CAPS = 1;
local $LJ::USER_EMAIL = 1;

my $dbh = LJ::get_db_writer();
sub check_alias {
    my ( $alias ) = @_;
    my ( $rcpt ) = $dbh->selectrow_array(
    	qq{SELECT rcpt FROM email_aliases
    	   WHERE alias=CONCAT(REPLACE(?, '-', '_'), '\@$LJ::USER_DOMAIN')},
    	undef, $alias
    );
    return defined $rcpt;
}

# Now you see them
ok( $u->update_email_alias, 'update_email_alias successful' );
ok( check_alias( $u->user ), 'alias present' );
my $username_with_dashes = $u->user;
$username_with_dashes =~ tr/_/-/;
ok( check_alias( $username_with_dashes ), 'alias with dashes "present"' );

# Now you don't
ok( $u->delete_email_alias, 'delete_email_alias successful' );
ok( !check_alias( $u->user ), 'alias absent' );
ok( !check_alias( $username_with_dashes ), 'alias with dashes "absent"' );
