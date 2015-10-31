package Map::Tube::Cookbook;

$Map::Tube::Cookbook::VERSION   = '0.02';
$Map::Tube::Cookbook::AUTHORITY = 'cpan:MANWAR';

=head1 NAME

Map::Tube::Cookbook - Cookbook for Map::Tube library.

=head1 VERSION

Version 0.02

=cut

use 5.006;
use strict; use warnings;
use Data::Dumper;

=head1 DESCRIPTION

Cookbook for L<Map::Tube> v3.11 or above library.

=head1 SETUP MAP

Currently L<Map::Tube> supports map data in XML format only. The structure of map
is listed as below:

    <?xml version="1.0" encoding="UTF-8"?>
    <tube name="Your-Map-Name">
        <lines>
           <line id="Line-ID"
                 name="Line-Name"
                 color="Line-Color-Code" />
           .....
           .....
           .....
           .....
        </lines>

        <stations>
           <station id="Station-ID"
                    name="Station-Name"
                    line="Line-ID:Station-Index"
                    link="Station-ID"
                    other_link="Link-Name:Station-ID" />
           .....
           .....
           .....
           .....
        </stations>
    </tube>

The root of the xml data is C<tube> having one optional attribute C<name> i.e map
name and two childrens C<lines> and C<stations>.

The node C<lines> has one or more children C<line>. The node C<line>  defines the
'Line' of the  map. The  node  C<line> has to have the attributes C<id>, C<name>.
Optionally it can have C<color> as well. They are explained as below:

    +-----------+---------------------------------------------------------------+
    | Attribute | Description                                                   |
    +-----------+---------------------------------------------------------------+
    |           |                                                               |
    | id        | Unique line id of the map. Ideally should be numeric but can  |
    |           | be alphanumeric. It shouldn't contain ",".                    |
    |           |                                                               |
    | name      | Line name of the map. It doesn't have to be unique as long as |
    |           | it has unique line id.                                        |
    |           |                                                               |
    | color     | Line color is optional. It should have color name or hexcode. |
    |           |                                                               |
    +-----------+---------------------------------------------------------------+

Example from L<Map::Tube::Delhi> as show below:

    <line id="Red" name="Red" color="#8B0000" />

The node C<stations>  has one or more children C<station>. The node C<station> is
used to represent  'station'  of  the map.It must have attributes C<id>, C<name>,
C<line> and C<link>. It can optionally have attribute C<other_link>.

    +------------+--------------------------------------------------------------+
    | Attribute  | Description                                                  |
    +------------+--------------------------------------------------------------+
    |            |                                                              |
    | id         | Unique station id of the map. Ideally should be numeric but  |
    |            | can be alphanumeric. It shouldn't contain ",".               |
    |            |                                                              |
    | name       | Station name of the map.It doesn't have to be unique as long |
    |            | as it has unique station id.                                 |
    |            |                                                              |
    | line       | Represents the station line alongwith the station index on   |
    |            | the line. It should be ":" separated, e.g. "Red:2". It means |
    |            | this is the first station on the line 'Red'. Station index   |
    |            | is NOT mandatory but nice to have. If the station crosses    |
    |            | more than one lines, then they should be listed as ","       |
    |            | separated. For Example, "Red:9,Green:16".                    |
    |            |                                                              |
    | link       | Represents all linked stations to this station. e.g. "B04"   |
    |            | If it is linked to more than one stations then they should   |
    |            | be listed as ", " separated. For example "B04,B02".          |
    |            |                                                              |
    | other_link | This attribute is optional. This is useful if the station is |
    |            | linked via other link and not by any of the lines, e.g. some |
    |            | stations are linked by tunnel. This can be defined as        |
    |            | "Tunnel:B02"                                                 |
    |            |                                                              |
    +------------+--------------------------------------------------------------+

Example from L<Map::Tube::London> without station index:

    <station id="B003"
             name="Bank"
             line="Central,DLR,Northern,Waterloo &amp; City"
             link="S002,S024,L013,M011,L012,W008"
             other_link="Tunnel:M009" />

Example from L<Map::Tube::Delhi> with station index:

    <station id="B03"
             name="Dwarka Sector 9"
             line="Blue:3"
             link="B04,B02" />

Let us create xml map for the following map:

      A(1)  ----  B(2)
     /              \
    C(3)  --------  F(6) --- G(7) ---- H(8)
     \              /
      D(4)  ----  E(5)

Below is the sample.xml represent the above map:

    <?xml version="1.0" encoding="UTF-8"?>
    <tube name="Sample">
        <lines>
           <line id="L1" name="L1" />
        </lines>
        <stations>
           <station id="L01" name="A" line="L1:1" link="L02,L03"         />
           <station id="L02" name="B" line="L1:2" link="L01,L06"         />
           <station id="L03" name="C" line="L1:3" link="L01,L04,L06"     />
           <station id="L04" name="D" line="L1:4" link="L03,L05"         />
           <station id="L05" name="E" line="L1:5" link="L04,L06"         />
           <station id="L06" name="F" line="L1:6" link="L02,L03,L05,L07" />
           <station id="L07" name="G" line="L1:7" link="L06,L08"         />
           <station id="L08" name="H" line="L1:8" link="L07"             />
        </stations>
    </tube>

=head1 CREATE MAP

You would need the latest package L<Map::Tube> v3.11 or above.

    package Sample::Map;

    use Moo;
    use namespace::clean;

    has xml => (is => 'ro', default => sub { 'sample.xml' });
    with 'Map::Tube';

    package main;
    use strict; use warnings;

    my $map = Sample::Map->new;
    print $map->get_shortest_route('A', 'D');

=head1 MAP GRAPH

To print  the  entire  map or just a particular line map, just install the plugin
L<Map::Tube::Plugin::Graph> and you have all the tools to create map image.

    use strict; use warnings;
    use MIME::Base64;
    use Sample::Map;

    my $map  = Sample::Map->new;
    my $name = $map->name;
    open(my $MAP_IMAGE, ">$name.png");
    binmode($MAP_IMAGE);
    print $MAP_IMAGE decode_base64($map->as_image);
    close($MAP_IMAGE);

=head1 FUZZY FIND

To enable the  fuzzy  search ability to the sample map, you would need to install
L<Map::Tube::Plugin::FuzzyFind>  and  you have everything you need to perform the
task.

    use strict; use warnings;
    use Sample::Map;

    my $map = Sample::Map->new;
    print 'Line contains: ', $map->fuzzy_find(search => 'a', object => 'lines');

=head1 VALIDATE MAP

There is handy  package L<Test::Map::Tube> that can help you in testing the basic
map structure and functionalities.

    use strict; use warnings;
    use Test::More;

    my $min_ver = 0.09;
    eval "use Test::Map::Tube $min_ver tests => 2";
    plan skip_all => "Test::Map::Tube $min_ver required" if $@;

    use Sample::Map;
    my $map = Sample::Map->new;
    ok_map($map);
    ok_map_functions($map);

=head1 SEARCH ALGORITHM

Lets take the same sample map.

      A(1)  ----  B(2)
     /              \
    C(3)  --------  F(6) --- G(7) ---- H(8)
     \              /
      D(4)  ----  E(5)

First thing we would do is build a table like below:

    +--------+---------------+
    | Vertex | Path | Length |
    +--------+------+--------+
    | A      |  -   |  INF   |
    | B      |  -   |  INF   |
    | C      |  -   |  INF   |
    | D      |  -   |  INF   |
    | E      |  -   |  INF   |
    | F      |  -   |  INF   |
    | G      |  -   |  INF   |
    | H      |  -   |  INF   |
    +--------+------+--------+

In the above table, the index on the left represents the  vertex we are going to.
The 'Path' field tell us which vertex precedes us in the path. The 'Length' field
is the length of the path from the starting vertex to that vertex, which we  have
initialized to INFinity.

Lets prepare the table assuming 'A' is the start point.

We begin by  indicating  that 'A'  can be reach itself with a path of length '0'.
This is better than infinity, so we replace INF with 0 in the length column.  And
we also place 'A' in the path column.

    +--------+---------------+
    | Vertex | Path | Length |
    +--------+------+--------+
    | A      |  A   |  0     |
    | B      |  -   |  INF   |
    | C      |  -   |  INF   |
    | D      |  -   |  INF   |
    | E      |  -   |  INF   |
    | F      |  -   |  INF   |
    | G      |  -   |  INF   |
    | H      |  -   |  INF   |
    +--------+------+--------+

Now we look at A's neighbour.All two of A's neighbours 'B' and 'C' can be reached
from 'A'  with  a path of length 1 (1 + the length of the path to A, which is 0).
For all two of them this better than inifinity.So we update their path and length
fields. And then enqueue them. because we will have to look at their  neighbour's
next.

    +--------+---------------+
    | Vertex | Path | Length |
    +--------+------+--------+
    | A      |  A   |  0     |
    | B      |  A   |  1     |
    | C      |  A   |  1     |
    | D      |  -   |  INF   |
    | E      |  -   |  INF   |
    | F      |  -   |  INF   |
    | G      |  -   |  INF   |
    | H      |  -   |  INF   |
    +--------+------+--------+

We dequeue 'B' and look at its neighbour 'A', 'C' and 'F'.The path through vertex
'B' to each of those vertices would have a length of 2(1 + the length of the path
to 'B', which is 1). For 'A' and 'C', this is worse than what is already in their
length,  so  we will do nothing for them. For 'F', the path of length 2 is better
than infinity, so we will put 2 in its length and 'B' in its path, since  it came
from 'B' and then we  will  enqueue it so we can eventually look at its neighbour
if necessary.

    +--------+---------------+
    | Vertex | Path | Length |
    +--------+------+--------+
    | A      |  A   |  0     |
    | B      |  A   |  1     |
    | C      |  A   |  1     |
    | D      |  -   |  INF   |
    | E      |  -   |  INF   |
    | F      |  B   |  2     |
    | G      |  -   |  INF   |
    | H      |  -   |  INF   |
    +--------+------+--------+

Next we dequeue 'C' and look at its neighbour 'A', 'F' and 'D'. The  path through
vertex 'C' to 'D' would have a length 2(1 + the length of the path to 'C'), which
is better than infinity, so we will put 'C' in its path and 2 in its length.  All
other would be worse than what they already have.

    +--------+---------------+
    | Vertex | Path | Length |
    +--------+------+--------+
    | A      |  A   |  0     |
    | B      |  A   |  1     |
    | C      |  A   |  1     |
    | D      |  C   |  2     |
    | E      |  -   |  INF   |
    | F      |  B   |  2     |
    | G      |  -   |  INF   |
    | H      |  -   |  INF   |
    +--------+------+--------+

Now we dequeue 'F' and look at its neighbour 'B', 'C', 'E' and 'G'. Now calculate
the length through 'F' to all its neighbour.

    'E' -> 'F' => 2 + 1 => 3 (better than infinity)
    'G' -> 'F' => 2 + 1 => 3 (better than infinity)

    +--------+---------------+
    | Vertex | Path | Length |
    +--------+------+--------+
    | A      |  A   |  0     |
    | B      |  A   |  1     |
    | C      |  A   |  1     |
    | D      |  C   |  2     |
    | E      |  F   |  3     |
    | F      |  B   |  2     |
    | G      |  F   |  3     |
    | H      |  -   |  INF   |
    +--------+------+--------+

Next we dequeue 'D' and look at its neighbour 'C' and 'E'. None of them have  got
any better length, Table remains the same as above.

    +--------+---------------+
    | Vertex | Path | Length |
    +--------+------+--------+
    | A      |  A   |  0     |
    | B      |  A   |  1     |
    | C      |  A   |  1     |
    | D      |  C   |  2     |
    | E      |  F   |  3     |
    | F      |  B   |  2     |
    | G      |  F   |  3     |
    | H      |  -   |  INF   |
    +--------+------+--------+

Now we dequeue 'E' and look at its neighbour 'D' and 'F'. Again none of them  got
any better length, Table still remains the same as above.

    +--------+---------------+
    | Vertex | Path | Length |
    +--------+------+--------+
    | A      |  A   |  0     |
    | B      |  A   |  1     |
    | C      |  A   |  1     |
    | D      |  C   |  2     |
    | E      |  F   |  3     |
    | F      |  B   |  2     |
    | G      |  F   |  3     |
    | H      |  -   |  INF   |
    +--------+------+--------+

Now we dequeue 'G' and look at its neighbour 'F' and 'H'.

    'H' -> 'G' => 3 + 1 => 4 (better than infinity)

    +--------+---------------+
    | Vertex | Path | Length |
    +--------+------+--------+
    | A      |  A   |  0     |
    | B      |  A   |  1     |
    | C      |  A   |  1     |
    | D      |  C   |  2     |
    | E      |  F   |  3     |
    | F      |  B   |  2     |
    | G      |  F   |  3     |
    | H      |  G   |  4     |
    +--------+------+--------+

Finally we dequeue 'H' and look at its neighbour 'G'. Again the length is not any
better than current, so we leave it.

Now we can  use  the above table to find out the shortest route starting from 'A'
to any other point in the map.

Lets  find  the  shortest route from 'A' to 'F', as per the table above, we start
with the end point 'F' and go backward like below:

    'F' => 'B' => 'A'

So the shortest route from 'A' to 'F' would be 'A', 'B' and 'F'.

How about shortest route from 'A' to 'G'.

    'G' => 'F' => 'B' => 'A'

Hence the shortest route from 'A' to 'G' would be 'A', 'B', 'F' and 'G'.

=head1 TEAM

=head2 Gisbert W Selke (GWS)

Author of  maps  like L<Glasgow|Map::Tube::Glasgow>, L<Lyon|Map::Tube::Lyon> etc.
Also the creator of wonderful plugin L<Fuzzy Find|Map::Tube::Plugin::FuzzyFind>.

=head2 Michal Spacek (SKIM)

Author of most of the maps e.g. L<Moscow|Map::Tube::Moscow>, L<Kiev|Map::Tube::Kiev>,
L<Warsaw|Map::Tube::Warsaw>,  L<Sofia|Map::Tube::Sofia> etc. He is the top in the
leader  board  of maximum number of maps. He has been the source behind many nice
features that we have.

=head2 Slaven Rezic (SREZIC)

Author of map like L<Berlin|Map::Tube::Berlin>.

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/Manwar/Map-Tube-Cookbook>

=head1 SEE ALSO

L<Map::Tube>

=head1 BUGS

Please report any bugs or feature requests to C<bug-map-tube-cookbook at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Map-Tube-Cookbook>.
I will  be notified and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Map::Tube::Cookbook

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Map-Tube-Cookbook>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Map-Tube-Cookbook>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Map-Tube-Cookbook>

=item * Search CPAN

L<http://search.cpan.org/dist/Map-Tube-Cookbook/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015 Mohammad S Anwar.

This  program  is  free software;  you can redistribute it and/or modify it under
the  terms  of the the Artistic License (2.0). You  may obtain a copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of Map::Tube::Cookbook
