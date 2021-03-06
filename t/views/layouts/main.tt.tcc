use utf8;

#------------------------------------------------------------------------
# Compiled template generated by the Template Toolkit version 2.27
#------------------------------------------------------------------------

Template::Document->new({
    METADATA => {
        'modtime' => '1541354060',
        'name' => 'layouts/main.tt',
    },
    BLOCK => sub {
    my $context = shift || die "template sub called without context\n";
    my $stash   = $context->stash;
    my $output  = '';
    my $_tt_error;
    
    eval { BLOCK: {
$output .=  "<!DOCTYPE html>\n<html lang=\"en\">\n\n<head>\n  <meta charset=\"";
#line 5 "/Users/stevedondley/perl/dancer2_sites/ZillTut/views/layouts/main.tt"
$output .=  $stash->get(['settings', 0, 'charset', 0]);
$output .=  "\">\n  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=yes\">\n  <title>";
#line 7 "/Users/stevedondley/perl/dancer2_sites/ZillTut/views/layouts/main.tt"
$output .=  $stash->get('title');
$output .=  "</title>\n  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n  <link rel=\"stylesheet\" href=\"";
#line 9 "/Users/stevedondley/perl/dancer2_sites/ZillTut/views/layouts/main.tt"
$output .=  $stash->get(['request', 0, 'uri_base', 0]);
$output .=  "/css/style.css\">\n  <link rel=\"stylesheet\" href=\"";
#line 10 "/Users/stevedondley/perl/dancer2_sites/ZillTut/views/layouts/main.tt"
$output .=  $stash->get(['request', 0, 'uri_base', 0]);
$output .=  "/javascripts/jquery-ui-1.12.1.custom/jquery-ui.min.css\">\n  <script src=\"//code.jquery.com/jquery-2.1.4.min.js\"></script>\n  <script type=\"text/javascript\">/* <![CDATA[ */\n      !window.jQuery && document.write('<script type=\"text/javascript\" src=\"";
#line 13 "/Users/stevedondley/perl/dancer2_sites/ZillTut/views/layouts/main.tt"
$output .=  $stash->get(['request', 0, 'uri_base', 0]);
$output .=  "/javascripts/jquery.js\"><\\/script>')\n  /* ]]> */</script>\n  <script src=\"/javascripts/jquery-ui-1.12.1.custom/jquery-ui.min.js\"></script>\n  <script src=\"https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js\"></script>\n</head>\n\n<body>\n    ";
#line 20 "/Users/stevedondley/perl/dancer2_sites/ZillTut/views/layouts/main.tt"
$output .=  $stash->get('content');
$output .=  "\n<div id=\"footer\">\nPowered by <a href=\"http://perldancer.org/\">Dancer2</a> ";
#line 22 "/Users/stevedondley/perl/dancer2_sites/ZillTut/views/layouts/main.tt"
$output .=  $stash->get('dancer_version');
$output .=  "\n</div>\n\n<script>\n\n// set up some globals\nvar elems = \$('.scrollspy');\nvar headers = {};\nvar headers_pos = [];\nvar current_active = \$(\"#sidebar a:first\");\n\n// calc header element positions\nfunction get_pos() {\n  headers = {};\n  headers_pos = [];\n  elems.each(function(index){\n    var pos = \$(this).position().top - 100;\n\n    var id = \$(this).attr('id');\n    pos_str = pos;\n    headers[pos_str] = id;\n    headers_pos.push(pos_str);\n  });\n  headers_pos.sort(function(a, b) {return a-b});\n}\n\n\n// Turn off autoscrolling when hovering over sidebar\nvar over;\n\n// We sometimes want to force sidebar to seek current location\n// when set to true\nvar seek = false;\n\n// when true, used to suppress any unwanted activation of sidebar links when\n// sliding sidebar in and out\nvar sidebar_change = false;\n\n// toggle sidebar visibility\n\$('#sb-slider').click(function() {\n  sidebar_change = true;\n  speed = 400;\n  \$('#sidebar').toggle('slide', speed);\n  \$('#sb-slider').toggleClass('collapsed', speed);\n  \$('#sb-slider').toggleClass('expanded', speed);\n  //if (\$(window).width() > 599) {\n    //\$('#content').fadeTo(200, 0);\n  //}\n\n  // The width of the #content area will change when the sidebar is opened\n  // and closed. This can create a drastic change the user sees in the viewport.\n  // To compensate we do back of the envelope calculations to guess at where in the\n  // content div to scroll to to minimize the change in content so the user\n  // does not have to scroll to get back to where they were before closing or\n  // opening the sidebar. This algorithm ususally gets us\n  // with 10 pixels or so but there are layout factors that could throw it\n  // further off. It works well enough.\n  if (\$(window).width() > 599) {\n    var curr_height = \$('#content').height();\n		var distance_to_top_of_page = \$(window).scrollTop(),\n				content_div_distance_from_top_of_page = \$('#content').offset().top ;\n        content_div_scroll_distance = distance_to_top_of_page - content_div_distance_from_top_of_page;\n    var href = current_active.attr('href');\n\n    active_elem_distance_to_top_of_content_div = \$('#content ' + href).position().top;\n		distance_into_active_element = content_div_scroll_distance - active_elem_distance_to_top_of_content_div;\n    over = false;\n    \$('#content').toggleClass('full', 1, 'linear', function() {\n      get_pos();\n      var new_curr_height = \$('#content').height();\n      var proportional_change = new_curr_height/curr_height;\n		  var new_active_elem_distance_to_top_of_content_div = \$('#content ' + href).position().top;\n      var new_scroll_pos = new_active_elem_distance_to_top_of_content_div + (distance_into_active_element * proportional_change);\n      var scroll_to = new_scroll_pos + content_div_distance_from_top_of_page;\n\n      // add a 5 pixel fudge factor to try to ensure content near the top of\n      // viewport remains in viewport\n      if (\$('#sb-slider').hasClass('collapsed')) {\n        \$(window).scrollTop( scroll_to + 5 );\n      } else {\n        \$(window).scrollTop( scroll_to - 5 );\n      }\n    });\n    //\$('#content').fadeTo(500, 1);\n  }\n  sidebar_change = false;\n  seek = true;\n} );\n\n\$('#sidebar a').click(function() {\n  \$('#sidebar a').removeClass('active');\n  \$(this).addClass('active');\n});\n\n// set proper initial location of sidebar slider toggle\n\$(function() {\n  if (\$(window).width() < 599) {\n    \$('#sb-slider').addClass('collapsed');\n  } else {\n    \$('#sb-slider').addClass('expanded');\n  }\n});\n\n// needed to suppress autoscrolling when scrolling manually in sidebar.\n// set to true when in sidebar except when we are actively sliding\n// the sidebar in and out to prevent spurious link activation\n\$(\"#sidebar\").hover(\n  function() { if (!sidebar_change) { over = true } },\n  function() { over = false; },\n);\n\n// init element positions\nget_pos();\n\n// recalc element positions when resized\n\$( window ).resize(function() {\n  get_pos();\n\n  // handle sidebar position when resizing window\n  if (\$(window).width() < 599) {\n    if (\$('#sb-slider').hasClass('expanded')) {\n      \$('#sidebar').css('display', 'inline-block');\n      \$('#sidebar-inner').css('display', 'block');\n    }\n  } else {\n    if (\$('#sb-slider').hasClass('collapsed')) {\n      \$('#content').addClass('full');\n    }\n  }\n\n});\n\n// call autoscroll feature very .030 seconds. Slower\n// periodicity will increase menu snappiness but\n// will degrade smoothness of menu animation effect.\nwindow.setInterval(function(){\n		autoscroll();\n}, 30);\n\n// scroll the table of contents automatically\n// called periodically as set by window.setInterval function\nfunction autoscroll() {\n    // get out of here if we are hovering over the sidebar\n    if (over == true) {\n      return;\n    }\n\n    // figure out where we are\n    var scrollTop = \$(window).scrollTop(),\n                    elementOffset = \$('#content').offset().top,\n		    distance = Math.abs(elementOffset - scrollTop);\n\n    // get id of header section located near top of viewport\n    var id;\n    var last = \$('#sidebar a:first').attr('href');\n    headers_pos.forEach(function(index) {\n      if (index > distance) {\n        if (!id) {\n          id = last;\n          return;\n        }\n      } else {\n        last = '#' + headers[index];\n      }\n    });\n    if (!id) {\n      id = last;\n    }\n\n    // get new jquery element and remove active class from last active element\n    var navElem = \$('a[href=\"' + id + '\"]');\n    navElem.addClass('active', 300);\n\n    if (!current_active.is(navElem) || seek == true) {\n      if (seek != true) {\n        current_active.removeClass('active', 300);\n      } else {\n        \$('#sidebar a').removeClass('active', 100);\n        current_active.addClass('active', 300);\n      }\n      seek = false;\n    } else {\n      return;\n    }\n    current_active = navElem;\n\n    // do the scrolling\n    var dft = navElem[0].getBoundingClientRect().top; // distance from top of viewport\n    var s = \$('#sidebar');\n    if (dft > s.innerHeight() * .5 || dft < s.scrollTop() ) {\n      \$('#sidebar').animate({ scrollTop: navElem.offset().top - s.offset().top + s.scrollTop() - s.innerHeight()/2 },\n				100,\n     );\n   }\n}\n\n// cargo-culted code for smooth scrolling in content area\n\$(function() {\n\$('a[href*=\"#\"]')\n  // Remove links that don't actually link to anything\n  .not('[href=\"#\"]')\n  .not('[href=\"#0\"]')\n  .click(function(event) {\n    // On-page links\n    if (\n      location.pathname.replace(/^\\//, '') == this.pathname.replace(/^\\//, '')\n      &&\n      location.hostname == this.hostname\n    ) {\n      // Figure out element to scroll to\n      var target = \$(this.hash);\n      target = target.length ? target : \$('[id=' + this.hash.slice(1) + ']');\n      // Does a scroll target exist?\n      if (target.length) {\n        // Only prevent default if animation is actually gonna happen\n        event.preventDefault();\n        \$('html, body').animate({\n          scrollTop: target.offset().top\n        }, 300, function() {\n          // Callback after animation\n          // Must change focus!\n          var \$target = \$(target);\n          \$target.focus();\n          if (\$target.is(\":focus\")) { // Checking if the target was focused\n            return false;\n          } else {\n            \$target.attr('tabindex','-1'); // Adding tabindex for elements not focusable\n            \$target.focus(); // Set focus again\n          };\n        });\n      }\n    }\n  });\n});\n\n\n</script>\n</body>\n</html>\n";
    } };
    if ($@) {
        $_tt_error = $context->catch($@, \$output);
        die $_tt_error unless $_tt_error->type eq 'return';
    }

    return $output;
},
    DEFBLOCKS => {

    },
});
