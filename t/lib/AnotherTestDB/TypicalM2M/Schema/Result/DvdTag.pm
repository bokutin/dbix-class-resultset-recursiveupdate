package AnotherTestDB::TypicalM2M::Schema::Result::DvdTag;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/IntrospectableM2M Core/);
__PACKAGE__->table("dvd_tag");
__PACKAGE__->add_columns(
    "dvd_id" => { data_type => 'integer' },
    "tag_id" => { data_type => 'integer' },
);
__PACKAGE__->set_primary_key("dvd_id", "tag_id");
__PACKAGE__->belongs_to("dvd", "AnotherTestDB::TypicalM2M::Schema::Result::Dvd", "dvd_id" );
__PACKAGE__->belongs_to("tag", "AnotherTestDB::TypicalM2M::Schema::Result::Tag", "tag_id" );

1;
