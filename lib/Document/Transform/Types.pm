package Document::Transform::Types;
BEGIN {
  $Document::Transform::Types::VERSION = '1.110400';
}

#ABSTRACT: Provides simple constraints Document::Transform

use warnings;
use strict;

use MooseX::Types -declare =>
[qw/
    Document
    Transform
    DocumentOrTransform
/];

use MooseX::Types::Moose(':all');
use MooseX::Types::Structured(':all');



subtype Document,
    as HashRef,
    where
    {
        exists($_->{document_id}) && not exists($_->{transform_id})
    };


subtype Transform,
    as HashRef,
    where
    {
        exists($_->{document_id}) && exists($_->{transform_id}) &&
        exists($_->{operations}) &&
        (ArrayRef[Dict[path => Str, value => Defined]])->check($_->{operations});
    };


subtype DocumentOrTransform,
    as Document|Transform;

1;


=pod

=head1 NAME

Document::Transform::Types - Provides simple constraints Document::Transform

=head1 VERSION

version 1.110400

=head1 TYPES

=head2 Document

    as HashRef

What defines a document for Document::Transform is pretty simple. A document
needs at least a document_id key defined and make sure it doesn't have a
transform_id key (because then it is a transform).

=head2 Transform

    as HashRef

A transform is defined as a HashRef with a few keys: document_id, transform_id,
and operations. operations needs to be an ArrayRef of hashes with the keys path
and value defined. 

=head2 DocumentOrTransform

    as Document|Transform;

This type is simply a union of the L</Transform> and L</Document> types.

=head1 AUTHOR

Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
