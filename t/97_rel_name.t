use strict;
use warnings;
use Test::More;
use Test::Exception;
use lib qw(t/lib);
use DBICTest;

my $schema = DBICTest->init_schema();
my $artist = $schema->resultset('Artist')->first;
my $cd     = $schema->resultset('CD')->first;

# CD_to_Producer ( test case for relname = column )
#   rel cd       -> self.cd       = foreign.cd_id
#   rel producer -> self.producer = foreign.producerid
{
    my $rs    = $schema->resultset('CD_to_Producer');
    my $count = $rs->count;
    ok $count;
    my $item  = $rs->first;
    lives_ok {
        DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update(
            resultset => $rs,
            updates   => {
                cd       => $item->cd->cdid,
                producer => $item->producer->producerid,
            },
        );
    };
    is $rs->count, $count;
    lives_ok {
        DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update(
            resultset => $rs,
            updates   => {
                cd       => { cdid       => $item->cd->cdid },
                producer => { producerid => $item->producer->producerid },
            },
        );
    };
    is $rs->count, $count;
}

# Artwork_to_Artist ( test case for relname != column )
#   rel artist  -> self.artist_id     = foreign.artistid
#   rel artwork -> self.artwork_cd_id = foreign.cd_id
{
    my $rs    = $schema->resultset('Artwork_to_Artist');
    my $item  = do {
        my $cd      = $schema->resultset('CD')->first;
        my $artist  = $schema->resultset('Artist')->first;
        my $artwork = $schema->resultset('Artwork')->create( { cd => $cd } );
        $rs->create(
            {
                artist  => $artist,
                artwork => $artwork,
            }
        );
    };
    my $count = $rs->count;
    ok $count;
    lives_ok {
        DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update(
            resultset => $rs,
            updates   => {
                artist  => $item->artist_id,
                artwork => $item->artwork_cd_id,
            },
        );
    };
    is $rs->count, $count;
    lives_ok {
        DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update(
            resultset => $rs,
            updates   => {
                artist  => { artistid => $item->artist_id     },
                artwork => { cd_id    => $item->artwork_cd_id },
            },
        );
    };
    is $rs->count, $count;
}

done_testing();
