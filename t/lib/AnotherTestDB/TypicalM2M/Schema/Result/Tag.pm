package AnotherTestDB::TypicalM2M::Schema::Result::Tag;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/IntrospectableM2M Core/);
__PACKAGE__->table("tag");
__PACKAGE__->add_columns(
  "id" => {
    data_type => 'integer',
    is_auto_increment => 1
  },
  'name' => {
    data_type => 'varchar',
    size      => 100,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( ['name'] );
__PACKAGE__->has_many("dvd_tags", "AnotherTestDB::TypicalM2M::Schema::Result::DvdTag", "tag_id");
__PACKAGE__->many_to_many('dvds', 'dvd_tags' => 'dvd');

1;
