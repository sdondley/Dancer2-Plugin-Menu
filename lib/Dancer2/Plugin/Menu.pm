package Dancer2::Plugin::Menu ;
use 5.010; use strict; use warnings;

# ABSTRACT: Automatically generate an HTML menu for your Dancer2 app

use Dancer2::Plugin;
use Dancer2::Core::Hook;
use Data::Dumper qw(Dumper);
use Storable qw (dclone);
use HTML::Element;
use List::Util 'first';

plugin_keywords qw ( menu_item );

has 'tree'       => ( is => 'rw', default => sub { { '/' => { children => {} } } } );
has 'html'       => ( is => 'rw', predicate => 1,);
has 'clean_tree' => ( is => 'rw', predicate => 1,);

sub BUILD {
  my $s = shift;

  $s->app->add_hook (Dancer2::Core::Hook->new (
    name => 'before_template',
    code => sub {
      my $tokens = shift;
      my $route = $tokens->{request}->route;
      if (!$s->has_clean_tree) {
        $s->clean_tree(dclone $s->tree);
      } else {
        $s->tree(dclone $s->clean_tree);
      }
      my @segments = split /\//, $route->spec_route;
      shift @segments;

      # set active
      my $tree = $s->tree->{'/'};
      foreach my $segment (@segments) {
        $tree->{children}{$segment}{active} = 1;
        $tree = $tree->{children}{$segment};
      }

      # generate html
      $s->html( HTML::Element->new('ul') );
      _get_menu($s->tree->{'/'}, $s->html);
      $tokens->{menu} = $s->html->as_HTML('', "\t", {});
    }
  ));
}

sub menu_item {
  my ($s, $xt_data, $route) = @_;
  my @segments = split /\//, $route->spec_route;
  my $tree = $s->tree;
  $segments[0] = '/';
  while (my $segment = shift @segments) {
    if ($s->tree->{$segment}) {
      if (!@segments) {
        if ($xt_data) {
          $tree->{$segment} = $xt_data;
        } else {
          $tree->{$segment}{title} = ucfirst($segment);
        }
      }
      $tree = $tree->{$segment}{children};
    } else {
      if (!$tree->{$segment}{children}) {
        $tree->{$segment}{children} = {};
        if (!@segments) {
          if ($xt_data) {
            $tree->{$segment} = $xt_data;
          } else {
            $tree->{$segment}{title} = ucfirst($segment);
          }
        } else {
          $tree->{$segment}{title} = ucfirst($segment) if !$tree->{$segment}{title};
        }
      }
      $tree = $tree->{$segment}{children};
    }
  }
}

sub _get_menu {
  my ($tree, $element) = @_;

  foreach my $child ( sort { ($tree->{children}{$a}{weight} || 5) <=> ($tree->{children}{$b}{weight} || 5)
                      || $tree->{children}{$a}{title} cmp $tree->{children}{$b}{title} } keys %{$tree->{children}} ) {

    my $li_this = HTML::Element->new('li');

    # set classes for breadcrumbs and css styling
    $li_this->attr(class => $tree->{children}{$child}{active} ? 'active' : '');

    # recurse
    if ($tree->{children}{$child}{children}) {
      $li_this->push_content($tree->{children}{$child}{title});
      my $ul      = HTML::Element->new('ul');
      $li_this->push_content($ul);
      $element->push_content($li_this);
      _get_menu($tree->{children}{$child}, $ul)
    } else {
      $li_this->push_content($tree->{children}{$child}{title});
      $element->push_content($li_this);
    }
  }
  return $element;
}


1; # Magic true value
# ABSTRACT: this is what the module does

__END__

=head1 SYNOPSIS

In your app:

  use Dancer2;
  use Dancer2::Plugin::Menu;

  menu_item(
    { title => 'My Parent Item', weight => 3 },
    get 'path' => sub { template },
  );

  menu_item(
    { title => 'My Child1 Item', weight => 3 },
    get 'path/menu1' => sub { template },
  );

  menu_item(
    { title => 'My Child2 Item', weight => 4 },
    get 'path/menu2' => sub { template },
  );

In your template file:

  <% menu %>

This will generage a hierarchical menu that will look like this when the
C<path/menu1> route is visted:

  <uL><ul><li class="active">Path<li class="active">My Child1 Item<li>My Child2 Item</li></ul></ul>

=head1 DESCRIPTION

This module generates HTML for routes wrapped in the C<menu_item> keyword. Menu
items will be injected into the template containing where the C<E<lt>% menu
%E<gt>> tag is located. Parent menu items are assigned to the C<E<lt>ul%E<gt>>
HTML tag and child are inside C<E<lt>li%E<gt>> tags. Menu items that are within
the current route are given the C<active> class so they can be styled.

The module is in early development stages and currently has few options. It has
not been heavily tested and there are likely bugs especially with dynaimc paths
which are completely untested at this time. The module should work and be
adqueate for simple menu structures, however.

=keyword menu_item( { [title => $str], [weight => $num] }, C<ROUTE METHOD> C<REGEXP>, C<CODE>)

Wraps a conventional route handler preceded by a required hash reference
containing data that will be applied to the route's endpoint.

Two keys can be supplied in the hash reference: a C<title> for the menu item and
a weight. The title will be used as the content for the menu items. The weight
will determine the order of the menu items. Heavier items (with larger values)
will "sink" to the bottom compared to sibling menu items sharing the same level
within the hierarchy. If two sibling menu items have the same weight, the menu
items will be ordered alphabetically.

Menu items that are not endpoints in the route or that are not supplied with a
title, will have a title automatically generated according to their segment
name. For example, this route:

  /categories/fun food/desserts

Will be converted to a hierachy of menu items entitled C<Categories>, C<Fun
food>, and C<Desserts>. Note that captialization is automatically added.
Automatic titles will be overridden with endpoint specific titles if they are
supplied later in the app.

If no weight is supplied it will default to a value of C<5>.

=head1 CONFIGURATION

Add a C<E<lt>% menu %E<gt>> tag in the appropriate location withing your Dancer2
template files. If desired, add css for C<E<lt>li%E<gt>> tags in the C<active>
class.

=head1 DEPENDENCIES

L<Dancer2>

L<HTML::Element>

=head2 DEVELOPMENT STATUS

This module is being actively supported and maintained. Suggestions for
improvement are welcome.

=head1 SEE ALSO

L<Dancer2>
