# ``WLMarkdown``

Recognise the WikiLayer markdown dialect and extract its reader-visible text.

Use ``Dialect/recognise(_:)`` when a host needs callouts, map embeds and node links
as structured values. Use ``Dialect/plainText(_:)`` for search, previews and
indexing.

The Go package [wlmarkdown](https://github.com/wikilayer/wlmarkdown) leads the
shared rules and corpora. Matching major and minor versions across the ports mean
they answer those cases alike.

## Topics

### Read a document

- ``Dialect``
- ``Dialect/recognise(_:)``
- ``Dialect/plainText(_:)``
- ``Reading``
- ``Found``
