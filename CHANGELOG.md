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
numbers move together to say the behaviour is the same. The README names where the
two parsers underneath differ.

Signatures are not repeated here; the README carries an example of each call. This
file says only what changed between versions and what that asks of you.

Changes are documented here in the format of
[Keep a Changelog](https://keepachangelog.com/).

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
