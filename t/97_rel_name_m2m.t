use strict;
use warnings;
use Test::More;
use Test::Exception;
use lib qw(t/lib);

#
# This test proves that t/97_rel_name.t just does not working by enabling IntrospectableM2M. 
#
# This test requires IntrospectableM2M to be enabled and the link table must belong_to relname != colname.
#
# Currently, the only table with IntrospectableM2M enabled is DBSchema::Result::Dvd,
# which cannot be used because the link is to relname = colname.
#
# This is the reason why I created AnotherTestDB::TypicalM2M::Schema.
#

use_ok 'AnotherTestDB::TypicalM2M::Schema';
my $schema = AnotherTestDB::TypicalM2M::Schema->connect('dbi:SQLite:dbname=:memory:');
$schema->deploy;

# DvdTag ( test case for relname != column )
#   rel dvd -> self.dvd_id = foreign.id
#   rel tag -> self.tag_id = foreign.id
{
    my $rs   = $schema->resultset('DvdTag');
    my $dvd  = $schema->resultset('Dvd')->create( { name => "dvd1" } );
    my $tag  = $schema->resultset('Tag')->create( { name => "tag1" } );
    my $item = $rs->create(
        {
            dvd => $dvd,
            tag => $tag,
        }
    );
    my $count = $rs->count;
    ok $count;
    for my $m2m_force_set_rel (1,0) {
        lives_ok {
            DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update(
                object    => $dvd,
                resultset => $schema->resultset('Dvd'),
                updates   => {
                    tags => [
                        { id => $tag->id },
                    ],
                },
                m2m_force_set_rel => $m2m_force_set_rel,
            );
        } "dvd many_to_many tags( { id => ... } ) m2m_force_set_rel=$m2m_force_set_rel";
        is $rs->count, $count;
        lives_ok {
            DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update(
                object    => $dvd,
                resultset => $schema->resultset('Dvd'),
                updates   => {
                    tags => [
                        $tag->id,
                    ],
                },
                m2m_force_set_rel => $m2m_force_set_rel,
            );
        } "dvd many_to_many tags([ids]) m2m_force_set_rel=$m2m_force_set_rel";
        is $rs->count, $count;
    }
}

done_testing();
