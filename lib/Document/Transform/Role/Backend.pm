package Document::Transform::Role::Backend;
BEGIN {
  $Document::Transform::Role::Backend::VERSION = '1.110400';
}

#ABSTRACT: Interface role to be consumed by backends

use Moose::Role;
use namespace::autoclean;





requires qw/fetch_transform fetch_document store_transform store_document/;

1;


=pod

=head1 NAME

Document::Transform::Role::Backend - Interface role to be consumed by backends

=head1 VERSION

version 1.110400

=head1 SYNOPSIS

    package MyBackend;
    use Moose;

    sub fetch_document { }
    sub fetch_transform { }
    sub store_document { }
    sub store_transform { }

    with 'Document::Transform::Role::Backend';
    1;

=head1 DESCRIPTION

Want to manage the backend to some other NoSQL database? Then you'll want to
consume this role and implement the needed functions. Generally, the store
functions should take data structures that conform the Types listed in
L<Document::Transform::Types> and the fetch methods should return those as well.

=head1 ROLE_REQUIRES

=head2 fetch_transform

This method must accept a string key and should return a
L<Document::Transform::Types/Transform>

=head2 fetch_document

This method must accept a string key and should return a
L<Document::Transform::Types/Document>

=head2 store_transform

This method should accept a L<Document::Transform::Types/Transform> and store it
in the backend.

=head2 store_document

This method should accept a L<Document::Transform::Types/Document> and store it
in the backend.

=head1 AUTHOR

Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

