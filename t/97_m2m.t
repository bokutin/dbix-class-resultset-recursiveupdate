use strict;
use warnings;
use Test::More;
use Test::Exception;
use lib qw(t/lib);
use DBICTest;

my $schema = DBICTest->init_schema();
my $artist = $schema->resultset('Artist')->first;
my $cd     = $schema->resultset('CD')->first;

is $artist->artworks->count, 0;

lives_ok {
    DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update(
        object    => $artist,
        resultset => $artist->result_source->resultset,
        updates   => {
            artworks => [
                { cd => $cd },
            ],
        },
    );
};

is $artist->artworks->count, 1;

lives_ok {
    DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update(
        object    => $artist,
        resultset => $artist->result_source->resultset,
        updates   => {
            artworks => [
                { cd => $cd },
            ],
        },
    );
};

is $artist->artworks->count, 1;

done_testing();
