package Document::Transform::Backend::MongoDB;
BEGIN {
  $Document::Transform::Backend::MongoDB::VERSION = '1.110400';
}

#ABSTRACT: Talk to a MongoDB via a simple interface

use Moose;
use namespace::autoclean;

use MongoDB;
use Throwable::Error;
use MooseX::Params::Validate;
use MooseX::Types::Moose(':all');
use Document::Transform::Types(':all');


has host =>
(
    is => 'ro',
    isa => Str,
    predicate => 'has_host',
);


has connection =>
(
    is => 'ro', 
    isa => 'MongoDB::Connection',
    default => sub
    {
        my $self = shift;
        unless($self->has_host)
        {
            Throwable::Error->throw
            ({
                message => 'host must be provided to use the default ' .
                    'connection constructor'
            });
        }
        return MongoDB::Connection->new(host => $self->host)
    },
    lazy => 1,
);


has database_name =>
(
    is => 'ro',
    isa => Str,
    predicate => 'has_database_name',
);


has database =>
(
    is => 'ro',
    isa => 'MongoDB::Database',
    default => sub
    {
        my $self = shift;
        unless($self->has_database_name)
        {
            Throwable::Error->throw
            ({
                message => 'database must be provided to use the default ' .
                    'db constructor'
            });
        }
        return $self->connection->${\$self->database_name};
    },
    lazy => 1,
);


has document_collection =>
(
    is => 'ro',
    isa => Str,
    predicate => 'has_document_collection',
);


has documents =>
(
    is => 'ro',
    isa => 'MongoDB::Collection',
    default => sub
    {
        my $self = shift;
        unless($self->has_document_collection)
        {
            Throwable::Error->throw
            ({
                message => 'document_collection must be provided to use the ' .
                    'default docs constructor'
            });
        }

        return $self->database->${\$self->document_collection};
    },
    lazy => 1,
);


has transform_collection =>
(
    is => 'ro',
    isa => Str,
    predicate => 'has_transform_collection',
);


has transforms =>
(
    is => 'ro',
    isa => 'MongoDB::Collection',
    default => sub
    {
        my $self = shift;
        unless($self->has_transform_collection)
        {
            Throwable::Error->throw
            ({
                message => 'transform_collection must be provided to use the ' .
                    'default transforms constructor'
            });
        }

        return $self->database->${\$self->transform_collection};
    },
    lazy => 1,
);


sub fetch_document
{
    my ($self, $key) = pos_validated_list
    (
        \@_,
        {isa => __PACKAGE__},
        {isa => Str},
    );

    return $self->documents->find_one({document_id => $key});
}


sub fetch_transform
{
    my ($self, $key) = pos_validated_list
    (
        \@_,
        {isa => __PACKAGE__},
        {isa => Str},
    );

    return $self->transforms->find_one({transform_id => $key});
}


sub store_document
{
    my ($self, $item, $safe) = pos_validated_list
    (
        \@_,
        {isa => __PACKAGE__},
        {isa => Document},
        {isa => Bool, optional => 1}
    );

    unless(exists($item->{_id}))
    {
        $self->documents->insert($item, ($safe ? {safe => 1} : ()) );
    }

    $self->documents->update({_id => $item->{_id}}, $item, ($safe ? {safe => 1} : ()));
}


sub store_transform
{
    my ($self, $item, $safe) = pos_validated_list
    (
        \@_,
        {isa => __PACKAGE__},
        {isa => Transform},
        {isa => Bool, optional => 1}
    );

    unless(exists($item->{_id}))
    {
        $self->transforms->insert($item, ($safe ? {safe => 1} : ()) );
    }

    $self->transforms->update({_id => $item->{_id}}, $item, ($safe ? {safe => 1} : ()));
}

with 'Document::Transform::Role::Backend';
__PACKAGE__->meta->make_immutable();
1;


=pod

=head1 NAME

Document::Transform::Backend::MongoDB - Talk to a MongoDB via a simple interface

=head1 VERSION

version 1.110400

=head1 SYNOPSIS

    use Document::Transform::Backend::MongoDB;

    my $backend = Document::Transform::Backend::MongoDB->new(
        host => $ENV{MONGOD}
        database_name => 'foo',
        transform_collection => 'transforms',
        document_collection => 'documents');

    my $doc = $backend->fetch_document('SOME_DOCUMENT');

=head1 DESCRIPTION

So you need Document::Transform to talk MongoDB. You're in luck, bucko, because this module is your godsend. And it comes by default! Now, there are a couple of different ways to instantiate this and different levels of attributes that can be filled. You can plug in the collections, you can plug in collection names and a database instance, you can plug in collection names, a database name, and connection instance. And if you don't have any instances then some connection info, database name, and collection names are all you need! So it is like you pick your level of support when calling into a PBS telethon.  

=head1 PUBLIC_ATTRIBUTES

=head2 host

    is: ro, isa: Str

host contains the host string provided to the MongoDB::Connection constructor.

=head2 connection

    is: ro, isa: MongoDB::Connection, lazy: 1

This attribute holds the MongoDB connection object. If this isn't provided and
it is accessed, a connection will be constructed using the L</host> attribute.

=head2 database_name

    is: ro, isa: Str

If the collections are not provided, this attribute must be provided as a means
to access the collections named in the L</transform_collection> and
L</document_collection>

=head2 database

    is: ro, isa: MongoDB::Database, lazy: 1

This attribute holds the MongoDB data in which the transform and document
collections are held. If this isn't provided in the constructor, one will be
constructed using the value from L</database_name>. If there is no value, an
exception will be thrown.

=head2 document_collection

    is: ro, isa: Str

If a collection is not passed to L</documents>, this attribute will be used to
access a collection from the L</database>.

=head2 documents

    is: ro, isa: MongoDB::Collection, lazy: 1

This attribute holds the collection from MongoDB that should be the documents
that should be fetched for transformation. If a collection is not passed to the
constructor, one will be pulled from the database using the value from
L</document_collection>

=head2 transform_collection

    is: ro, isa: Str

If a collection is not passed to L</transforms>, this attribute will be used to
access a collection from the L</database>.

=head2 transforms

    is: ro, isa: MongoDB::Collection, lazy: 1

This attribute holds the collection from MongoDB that should be the transforms
that should be fetched for transformation. If a collection is not passed to the
constructor, one will be pulled from the database using the value from
L</transform_collection>

=head1 PUBLIC_METHODS

=head2 fetch_document

    (Str)

This method implements the L<Docoument::Transform::Role::Backend/fetch_document>
method. It takes a single string key that should match a document within the
documents collection with the right document_id attribute. See the
L<Document::Transform/SYNOPSIS> for a description of the expected document
format.

=head2 fetch_transform

    (Str)

This method implements the L<Docoument::Transform::Role::Backend/fetch_transform>
method. It takes a single string key that should match a transform within the
transforms collection with the right transform_id attribute. See the
L<Document::Transform/SYNOPSIS> for a description of the expected transform
format.

=head2 store_document

This method implements the L</Document::Transform::Role::Backend/store_document>
method with one key notable option. In addition to the document to store, a
second boolean value can be passed to denote whether a "safe" insert/update
should take place.

=head2 store_transform

This method implements the L</Document::Transform::Role::Backend/store_transform>
method with one key notable option. In addition to the transform to store, a
second boolean value can be passed to denote whether a "safe" insert/update
should take place.

=head1 AUTHOR

Nicholas R. Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
