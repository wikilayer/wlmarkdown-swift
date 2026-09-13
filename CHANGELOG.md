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
the corpus does not reach everything: the difference it cannot reach is named below,
and the README says where the parsers underneath differ. Which version of
swift-markdown this is built against is in `Package.swift`, where it cannot go stale.

The version is 0.x because the shape is still settling: every reader of these two
libraries so far has moved something in their API rather than working around it, so
a minor may still change an answer you relied on. Read the entry before taking one.

## Where the two ports do not agree

One difference is left, and no corpus case can reach it, so a green corpus does not
prove the ports answer alike. It is open in the newest release, the first listed
below:

- A bare URL is a link in Go and plain words here. The dialect asks every port to
  switch linkifying on; swift-markdown offers no way to, so this one cannot until it
  does.

Signatures are not repeated here; the README carries an example of each call. This
file says only what changed between versions and what that asks of you.

Changes are documented here in the format of
[Keep a Changelog](https://keepachangelog.com/).

## 0.6.0 - 2026-09-13

### Fixed

- `declined(in:)` no longer reports a quote the dialect made an unreadable block of.
  It answered about quotes `place(in:)` turned down, and since 0.5.0 that call also
  stays silent about a point nowhere on Earth — so a host logging or badging what was
  turned down complained about a block it had just drawn, and the leading port
  reported nothing for the same document. If you wired `declined(in:)` to anything a
  reader sees, this is the release that stops it crying wolf.
- The words of an unreadable block are the whole quote's, not its first paragraph's.

  ```
  > [!MAP]
  > 999, 20
  >
  > The street I meant.
  ```

  handed back `[!MAP] 999, 20` and now hands back `[!MAP] 999, 20 The street I
  meant.` Everything written below the coordinates was missing from `recognise` and
  from `unreadable(in:)`, which is the one place the author is shown what to fix.
  0.5.0 said those words came back exactly as they stand in the source; for a quote
  of more than one paragraph that was not true, and this is where it becomes true.
  Markdown among them has always survived here, links included, so that half of the
  leading port's fix for the same release has no counterpart in this one.
- A callout no longer takes the words of a construct nested deeper than its own
  children. A map inside a list inside a callout left its marker and coordinates
  among the callout's words, so a host drawing that callout printed `[!MAP]` and a
  pair of numbers in the middle of a sentence, and drew the map underneath as well.
  The leading port answered this correctly and nothing held the line; the corpus
  holds it now, and the list of differences below is one line shorter for it.

### Changed

- The corpus now names what the dialect turned down, case by case, and this port is
  asked it there rather than in tests of its own. Two cases that lived only here
  moved into it as well, a caption outside ASCII and a caption opening on tabs, so
  the leading port is asked them too.
- The minor moves with [the leading port](https://github.com/wikilayer/wlmarkdown),
  which fixes two answers of its own for this release and adds `Kinds()`, a list of
  node kinds that matters only to a host registering goldmark renderers. There is
  nothing to match here: this port hands back `Found` values, and `markers`,
  `classes` and `schemes` already name everything that can arrive in one.

  Between them the four fixes close every difference the corpus can reach, and both
  ports now answer all of it alike. Matching major and minor said that much from
  0.4.0 on and were wrong to; what makes it true now is the corpus asking about what
  was turned down as well.

## 0.5.0 - 2026-09-13

### Added

- `Reading.unreadable(in:)`, the words a quote wrote as a map when its point is
  nowhere on Earth, exactly as they stand in the source. It answers about the
  quotes `place(in:)` now turns down, and about no others.

### Changed

- A point nowhere on Earth is no longer a place. `rules.yaml` now names how far a
  coordinate may go, `90` and `180`, beside the alphabets it already spells out, and
  both are compared digit by digit rather than through a `Double`, so a number too
  long for one is judged by the same rule. `recognise` returns `kind: "unreadable"`
  carrying the words as written, and `place(in:)` returns nothing for such a quote.

  Show them. What the block looks like is yours, as a callout's colour is; that the
  reader sees the coordinates and learns they cannot be read is the point, because
  whoever typed them is the only one who can fix them. Before this, `999, 999` drew
  a map of a place the page does not name.

  The bound is the last place there is, not the first one missing: `-90, 180` is a
  point at the pole and stays a map. Four cases in the corpus hold that line — a
  latitude past the pole, a longitude past the meridian, the pole itself, and a run
  of digits no `Double` could hold — so a port that answers any of them differently
  goes red here rather than surprising a reader.

## 0.4.0 - 2026-09-13

### Fixed

- `calloutClass(of:)`, `place(in:)` and `declined(in:)` answer about where a quote
  stands, not only about the quote. An ordinary quote stops the dialect, so a `[!MAP]`
  written inside one is not a map — `recognise` has always said so, and these three
  did not: a host asking about that inner quote was told it was a map and drew one
  where the site shows a quote. The same blindness left `declined(in:)` silent about
  it, so the marker was missing from what the dialect made and from what it turned
  down at once. That is a third way a quote is turned down, beside the two 0.3.4
  named: a marker under a quote the dialect never entered.
- `Dialect()` reads and parses the rules once for the process rather than on every
  construction. A host building one per link paid a YAML parse per link.

## 0.3.4 - 2026-09-13

### Added

- `Reading.declined(in:)`, the quotes this dialect declined to make a construct of,
  one entry per quote with the marker it carried: a map whose coordinates did not
  read, or a callout written inside another callout's quote, which the dialect
  leaves as it found it. The leading port has answered this since its own 0.3.0, and
  until now a host here had to walk the tree itself and write out the dialect's own
  rule for what opens a construct. Equal major and minor are supposed to say the two
  ports behave alike; on this they did not.

## 0.3.3 - 2026-09-13

### Fixed

- A line opening on tabs lost its tail. cmark reports the same columns for a line
  whether or not tabs precede its content, so reading the source by those columns
  cut the line short; the caption of a map written that way arrived missing
  characters. A slice whose width does not match what the columns claim is now
  refused, and the parsed text is used instead.

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
