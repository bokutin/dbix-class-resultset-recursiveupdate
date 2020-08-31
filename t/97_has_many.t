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
        resultset => $schema->resultset('Artwork'),
        updates   => {
            cd => $cd,
        },
    );
} "prepare test data. (insert Artwork row, because it's a new fk_id)";

lives_ok {
    DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update(
        resultset => $schema->resultset('Artwork'),
        updates   => {
            cd => $cd,
        },
    );
} "prepare test data. (update Artwork row, because it has the same fk_id)";

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
} "insert Artwork_to_Artist row";

is $artist->artworks->count, 1;

lives_ok {
    DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update(
        object    => $artist,
        resultset => $artist->result_source->resultset,
        updates   => {
            artworks => [],
        },
    );
} "delete Artwork_to_Artist row";

is $artist->artworks->count, 0;

lives_ok {
    DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update(
        object    => $artist,
        resultset => $artist->result_source->resultset,
        updates   => {
            artworks => [
                $cd->id,
            ],
        },
    );
} "insert Artwork_to_Artist row by fk_id as POD";

is $artist->artworks->count, 1;

done_testing();
