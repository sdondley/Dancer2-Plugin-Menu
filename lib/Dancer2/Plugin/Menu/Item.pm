package Dancer2::Plugin::Menu::Item ;

# ABSTRACT: Object representing a Dancer2 menu item
use Moo;

has 'url' => (is => 'ro', isa => 'Str', required => 1);
has 'path' => (is => 'ro', isa => 'Str', required => 1);
