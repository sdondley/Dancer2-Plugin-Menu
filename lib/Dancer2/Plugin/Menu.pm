package Dancer2::Plugin::Menu ;
use 5.010; use strict; use warnings;

# ABSTRACT: Automatically generate an HTML menu for your Dancer2 app

use Storable     'dclone';
use List::Util   'first';
use Data::Dumper 'Dumper';
use HTML::Element;
use Dancer2::Plugin;
use Dancer2::Core::Hook;

plugin_keywords qw ( menu_item );

### ATTRIBUTES ###
# tree is the current active tree with "active" tags
# clean_tree is tree without "active" tags, used to easily reset tree
# html contains HTML generated from the tree

# Separting the HTML from a logical data structure is probably slightly more
# expensive but makes the code cleaner and easier to follow.

has 'tree'       => ( is => 'rw', default => sub { { '/' => { children => {} } } } );
has 'clean_tree' => ( is => 'rw', predicate => 1,);
has 'html'       => ( is => 'rw');
###################

# set up before_template hook to make the menu dynamic using "active" property
sub BUILD {
  my $s = shift;

  $s->app->add_hook (Dancer2::Core::Hook->new (
    name => 'before_template',
    code => sub {

      # reset or init the trees
      $s->has_clean_tree ? $s->tree(dclone $s->clean_tree)
                         : $s->clean_tree(dclone $s->tree);

      # set active menu items
      my $tokens = shift;
      my @segments = split /\//, $tokens->{request}->route->spec_route;
      shift @segments; # get rid of blank segment
      my $tree = $s->tree->{'/'};
      foreach my $segment (@segments) {
        $tree->{children}{$segment}{active} = 1;
        $tree = $tree->{children}{$segment};
      }

      # tear down and regenerate html and send to template
      $s->html( HTML::Element->new('ul') );
      _get_menu($s->tree->{'/'}, $s->html);
      $tokens->{menu} = $s->html->as_HTML('', "\t", {});
    }
  ));
}

# init the tree; called for each route wrapped in the menu_item keyword
sub menu_item {
  my ($s, $xt_data, $route) = @_;
  my $tree = $s->tree;
  my @segments = split /\//, $route->spec_route;
  $segments[0] = '/'; # replace blank segment with root segment

  # add the path segments and associate data with tree nodes
  while (my $segment = shift @segments) {
    my $title = ucfirst($segment);
    my $weight = 5;
    $xt_data->{title} //= $title;
    $xt_data->{weight} //= $weight;

    # more segments after this one so extend tree if next segment doesn't exist
    if (@segments) {
      if (!$tree->{$segment}{children}) {
        $tree->{$segment}{children} = {};
      }
    # add xl_data if we are at the end of a path and therefore route
    } elsif (!$tree->{$segment}{children}) {
      $tree->{$segment} = $xt_data;
      $tree->{$segment}{protected} = 1;  # don't let other routes overwrite
      next; # we can bail early on iteration and save 2 zillionths of a second
    }

    # not at the end of an existing path, determine which data to add to tree node
    if (!$tree->{$segment}{protected}) {
      # if at end of the route, add xt_data; otherwise defaults are used
      if (!@segments) {
        ($title, $weight)            = ($xt_data->{title}, $xt_data->{weight});
        $tree->{$segment}{protected} = 1;
      }
      $tree->{$segment}{title}     = $title;
      $tree->{$segment}{weight}    = $weight;
    }
    $tree = $tree->{$segment}{children};
  }
}

# generate the HTML based on the contents of the tree
sub _get_menu {
  my ($tree, $element) = @_;

  # sort sibling children menu items by weight and then by name
  foreach my $child (
    sort { ( $tree->{children}{$a}{weight} <=> $tree->{children}{$b}{weight} )
      ||   ( $tree->{children}{$a}{title}  cmp $tree->{children}{$b}{title}  )
         } keys %{$tree->{children}} ) {

    # create menu item list element with classes for css styling
    my $li_this = HTML::Element->new('li');
    $li_this->attr(class => $tree->{children}{$child}{active} ? 'active' : '');

    # add HTML elements for menu item; recurse if menu item has children itself
    $li_this->push_content($tree->{children}{$child}{title});
    if ($tree->{children}{$child}{children}) {
      my $ul      = HTML::Element->new('ul');
      $li_this->push_content($ul);
      $element->push_content($li_this);
      _get_menu($tree->{children}{$child}, $ul)
    } else {
      $element->push_content($li_this);
    }
  }
  return $element;
}

1; # Magic true value

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

This will generate a hierarchical menu that will look like this when the
C<path/menu1> route is visted:

  <ul><li class="active">Path
      <ul><li class="active">My Child1 Item</li>
          <li>My Child2 Item</li>
      </ul>
  </ul>

=head1 DESCRIPTION

This module generates HTML for routes wrapped in the C<menu_item> keyword. Menu
items will be injected into the template wherever the C<E<lt>% menu %E<gt>> tag
is located. Child menu items are wrapped in C<E<lt>li%E<gt>> HTML tags which are
themselves wrapped in a C<E<lt>ul%E<gt>> tag associated with the parent menu
item. Menu items within the current route are given the C<active> class so they
can be styled.

The module is in early development stages and currently has few options. It has
not been heavily tested and there are likely bugs especially with dynaimc paths
which are completely untested at this time. The module should work and be
adqueate for simple menu structures, however.

=keyword menu_item( { [title => $str], [weight => $num] }, C<ROUTE METHOD> C<REGEXP>, C<CODE>)

Wraps a conventional route handler preceded by a required hash reference
containing data that will be applied to the route's endpoint.

Two keys can be supplied in the hash reference: a C<title> for the menu item and
a C<weight>. The C<title> will be used as the content for the menu items. The
C<weight> will determine the order of the menu items. Heavier items (with larger
values) will "sink" to the bottom compared to sibling menu items sharing the
same level within the hierarchy. If two sibling menu items have the same weight,
the menu items will be ordered alphabetically.

Menu items that are not endpoints in the route or that don't have a C<title>,
will automatically generate a title according to the path segment's name. For
example, this route:

  /categories/fun food/desserts

Will be converted to a hierachy of menu items entitled C<Categories>, C<Fun
food>, and C<Desserts>. Note that captialization is automatically added.
Automatic titles will be overridden with endpoint specific titles if they are
supplied in a later C<menu_item> call.

If the C<weight> is not supplied it will default to a value of C<5>.

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
