package Dancer2::Plugin::Menu::Tree ;
use Moo;
use Data::Dumper qw(Dumper);

has name => (is => 'ro');
has subs => (is => 'rw', isa => sub { die unless ref shift eq 'ARRAY' });

sub add_menu_item {
  my ($self, @names)  = @_;
  my $next_name       = shift @names;

  # names empty: do nothing
  return unless defined $next_name;
  $next_name ||= '/';
  print Dumper $next_name;

  # find or create a matching tree
  my $subtree = first {$_->name eq $next_name} @{$self->subs} if @{$self->subs};
  push @{$self->subs}, $subtree = Dancer2::Plugin::Menu::Tree->new(name => $next_name, subs => [])
      unless defined $subtree;

  # recurse
  $subtree->add_menu_item(@names);
}

1;
