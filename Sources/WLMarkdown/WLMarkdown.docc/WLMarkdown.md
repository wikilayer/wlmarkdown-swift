# ``WLMarkdown``

Recognise the WikiLayer markdown dialect and extract its reader-visible text.

Use ``Dialect/recognise(_:)`` when a host needs callouts, map embeds and node links
as structured values. Use ``Dialect/plainText(_:)`` for search, previews and
indexing.

The Go package [wlmarkdown](https://github.com/wikilayer/wlmarkdown) leads the
shared rules and corpora. Matching major and minor versions across the ports mean
they answer those cases alike.

The library recognises but does not render, decorate, or resolve the constructs it
finds. Those choices remain with the application holding the pages.

> Important: A ``Reading`` must be created from the same source string as the
> `Document` it answers questions about.

## Topics

### Read a document

- ``Dialect``
- ``Dialect/recognise(_:)``
- ``Dialect/plainText(_:)``
- ``Reading``
- ``Found``

### Inspect a parsed tree

- ``Reading/calloutClass(of:)``
- ``Reading/place(in:)``
- ``Reading/unreadable(in:)``
- ``Reading/declined(in:)``
- ``Reading/opensAConstruct(_:)``
- ``Reading/isAutolink(_:)``

### Discover the dialect

- ``Dialect/markers``
- ``Dialect/classes``
- ``Dialect/schemes``
- ``Dialect/scheme(in:)``
- ``Declined``
