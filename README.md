# wlmarkdown-swift

The WikiLayer markdown dialect in Swift: GitHub-flavoured markdown, and then the
constructs the dialect adds of its own. It is the Swift port of
[wlmarkdown](https://github.com/wikilayer/wlmarkdown), which leads, and it answers
the same corpus of cases the Go port answers.

```swift
let found = Dialect().recognise("> [!TIP]\n> Try the shorter form.\n")
```

`Found` comes back flat and in document order, one entry per construct: a callout
with its class, a map with its point and caption, a link with the scheme it names
and the destination exactly as written.

## What it recognises

A blockquote whose first line is exactly `[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`,
`[!WARNING]` or `[!CAUTION]` is a callout of that class. A marker sharing its line
with words, or written in lower case, leaves an ordinary quote.

A `[!MAP]` marker followed by a line of two numbers is a map embed, and whatever
follows is its caption. Both numbers are digits carrying an optional sign and an
optional fraction, and nothing else: no exponent, no hexadecimal, no infinity. They
come back as the source wrote them, digit for digit, because rounding a coordinate
moves the point.

A link may name a node instead of a URL, under the scheme `page:` or `block:`. The
destination comes back character for character; which names exist is a question the
store answers.

`markers`, `classes` and `schemes` name what the dialect opens constructs with and
what can come back in `Found`. Read them rather than writing down what is in them
today.

## Asking about a document you parsed yourself

A host that builds its own tree out of swift-markdown holds a `BlockQuote` and needs
to know what it is. `Reading` answers that, over the source the document was parsed
from:

```swift
let source = page.body
let reading = Reading(source)
for quote in Document(parsing: source).children.compactMap({ $0 as? BlockQuote }) {
    if let place = reading.place(in: quote) { … }          // lat, lng, caption
    if let written = reading.unreadable(in: quote) { … }   // a point nowhere on Earth
    if let named = reading.calloutClass(of: quote) { … }   // note, tip, warning …
}
```

A quote written as a map whose point is outside `90` and `180` is not a place, so
`place(in:)` stays silent about it and `unreadable(in:)` hands back the words as
they stand in the source. Show them: the only person who can fix such coordinates
is the one who typed them.

`opensAConstruct(_:)` says whether a quote carries any of the dialect's markers, and
`isAutolink(_:)` tells a bracketed link from `<https://example.com>`. `Dialect`'s
`scheme(in:)` names the scheme of a destination, or none.

`reading.declined(in: document)` hands back the quotes the dialect turned down, one
entry per quote with the marker it carried: a map whose coordinates did not read, or
a callout written inside another callout's quote. Deciding that from outside would
mean writing the dialect's rule for what opens a construct a second time.

A `Reading` is built on one source string and answers by line and column, so it must
be the string its document was parsed from.

## What it does not do

It recognises. A title for a callout, an icon, a colour, a link resolved against a
store: each of those belongs to whoever holds the pages, because a web page answers
them one way and a phone app another.

## The corpus

`Sources/WLMarkdown/Resources/rules.yaml` holds what the dialect knows and
`Tests/WLMarkdownTests/Resources/dialect.yaml` the cases that define it. Both are
copies of the files in the leading port, refreshed with `make sync-corpus`, and the
whole corpus runs here on every build. A case answered differently by the two ports
goes red rather than reaching a reader.

## Where the two ports differ

Both read the same rules and answer the same cases, but they stand on different
parsers, goldmark and [swift-markdown](https://github.com/swiftlang/swift-markdown),
and the differences below are theirs rather than the dialect's.

A marker line is read from the source rather than from the parsed text, because
cmark trims a trailing space off a text node while goldmark keeps it, and
`[!NOTE] ` with a space after it is not a marker. Where cmark rebuilds a paragraph
and drops its source range, which it does when a table follows, the parsed text is
used instead.

A task list item keeps its `[ ]` in the text cmark hands back, so the mark is
stripped here; goldmark reports the checkbox as a node of its own and never puts it
in the words.

A line whose source cannot be identified from the columns cmark reports — a line
opening on tabs, whose expansion those columns do not carry — falls back to the
parsed text. What that costs is the markdown of a caption written that way, a link
arriving as its words rather than as `[words](page:1)`. Reading it blind would cost
the tail of the line instead.

Two differences are the dialect's and not a parser's, and neither is closed here.
A bare URL is a link on the site and plain words here, because the dialect asks a
port to switch linkifying on and swift-markdown offers no way to. And what a
callout's words are when a construct is nested deeper than its own children is
answered differently by the two ports. Both are named in the changelog and neither
has a corpus case, which is why the corpus alone does not prove the ports agree.

## Running it

```sh
make test          # the corpus, plus the rules tests
make lint          # swiftlint
make sync-corpus   # refresh rules.yaml and dialect.yaml from the leading port
```
