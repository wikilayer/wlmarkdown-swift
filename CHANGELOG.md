# Changelog

A Swift package, `WLMarkdown`, built on
[swift-markdown](https://github.com/swiftlang/swift-markdown). It recognises the
markdown dialect of WikiLayer, a wiki whose pages are a tree of nodes: GitHub-flavoured
markdown plus callouts, map embeds, and links naming a node instead of a URL.

```markdown
> [!WARNING]
> This cannot be undone.

Start at [the front page](page:home), or at [one paragraph](block:50386) of it.
```

It recognises and does nothing else. What title that callout wears, which icon and
colour it gets, which address `page:home` resolves to: a web page answers each of
those one way and a phone app another, so each belongs to the application holding
the pages rather than to a parser.

This is a port. [wlmarkdown](https://github.com/wikilayer/wlmarkdown) leads, both
ports read the same rules and answer the same corpus, and the major and minor
numbers move together to say so. What they promise is agreement on the corpus, and
the corpus does not reach everything: the two differences it cannot reach are named
below, and the README says where the parsers underneath differ.

## Where the two ports do not agree

Neither has a corpus case, so a green corpus does not prove the ports answer alike.
Both are open at the version above:

- A bare URL is a link in Go and plain words here. The dialect asks every port to
  switch linkifying on; swift-markdown offers no way to, so this one cannot until it
  does.
- A construct nested deeper than a callout's own children — a map inside a list
  inside the callout — leaves its marker and coordinates among the callout's words
  here, and does not in Go.

Signatures are not repeated here; the README carries an example of each call. This
file says only what changed between versions and what that asks of you.

Changes are documented here in the format of
[Keep a Changelog](https://keepachangelog.com/).

## 0.3.4 - 2026-09-13

### Added

- `Reading.declined(in:)`, the quotes this dialect declined to make a construct of,
  one entry per quote with the marker it carried: a map whose coordinates did not
  read, or a callout written inside another callout's quote, which the dialect
  leaves as it found it. The leading port has answered this since its own 0.3.0, and
  until now a host here had to walk the tree itself and write out the dialect's own
  rule for what opens a construct. Equal major and minor are supposed to say the two
  ports behave alike; on this they did not.

### Fixed

- `README.md` names the calls 0.3.1 added. The changelog said the README carried an
  example of each and it carried one, for `recognise`.

## 0.3.3 - 2026-09-13

### Fixed

- A line opening on tabs lost its tail. cmark reports the same columns for a line
  whether or not tabs precede its content, so reading the source by those columns
  cut the line short; the caption of a map written that way arrived missing
  characters. A slice whose width does not match what the columns claim is now
  refused, and the parsed text is used instead.

### Changed

- The identifier-name rule is no longer switched off in `.swiftlint.yml`.

## 0.3.2 - 2026-09-13

### Fixed

- swift-markdown is required by version rather than by a pinned revision. A package
  pinned to a revision cannot be taken by version at all, so 0.3.0 and 0.3.1 could
  be cloned but not depended on, which is most of what a library is for. The corpus
  answers the same on 0.8.0, the version now asked for.

## 0.3.1 - 2026-09-13

### Added

- `Reading`, which answers about nodes you have already parsed rather than about a
  source string: `calloutClass(of:)` for a blockquote, `place(in:)` for one holding
  a point, `opensAConstruct(_:)` for a quote carrying any of the dialect's markers,
  and `isAutolink(_:)` for a link. `Dialect.scheme(in:)` names the scheme of a
  destination, or none. A host building its own tree out of swift-markdown needs
  these; with only `recognise` it would have to write the dialect's rules a second
  time to know what it is looking at. The leading port answers the same questions
  through its goldmark extensions, which is why this is wiring rather than a change
  of behaviour, and why the third number is the only one that moved.

## 0.3.0 - 2026-09-13

First release, answering the corpus as the leading port's 0.3.0 does.

### Added

- `Dialect()` and `recognise(_:)`, returning the flat list of what the dialect found
  in document order: callouts with their class, map embeds with their point and
  caption, links with the scheme they name and the destination as written.
- `markers`, `classes` and `schemes`, naming what opens a construct and what can
  come back in a `Found`. A later version may add a value to any of the three; none
  of the values already there will change what it means.
- The corpus of the leading port, run here on every build, so a case the two ports
  answer differently is a red test rather than a reader's surprise.
