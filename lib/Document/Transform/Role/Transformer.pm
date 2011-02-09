package Document::Transform::Role::Transformer;
BEGIN {
  $Document::Transform::Role::Transformer::VERSION = '1.110400';
}

#ABSTRACT: Provides an interface role for Transformers implementations

use Moose::Role;
use namespace::autoclean;


requires 'transform';

1;


=pod

=head1 NAME

Document::Transform::Role::Transformer - Provides an interface role for Transformers implementations

=head1 VERSION

version 1.110400

=head1 SYNOPSIS

    package MyTransformer;
    use Moose;

    sub transform() { say 'Yarp!'; }

    with 'Document::Transform::Role::Transformer';
    1;

=head1 DESCRIPTION

Want to implement your own transformer and feed it directly to
L<Document::Transform>? Then this is your role.

Simply implement a suitable transform method and consume the role.

=head1 ROLE_REQUIRES

=head2 transform

This role requires that you provide the transform method. If merely substituting
your own Transformer implementation, transform will need to take two arguments,
a L<Document::Transform::Types/Document> and a
L<Document::Transform::Types/Transform> with the expectation that the operations
contained with in the Transform are executed against the Document, and the
result returned. 

=head1 AUTHOR

Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

