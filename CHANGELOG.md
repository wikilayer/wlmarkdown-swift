# Changelog

Notable changes to `WLMarkdown` are documented here in the format of
[Keep a Changelog](https://keepachangelog.com/). The Go package
[wlmarkdown](https://github.com/wikilayer/wlmarkdown) leads the shared rules and
corpora; matching major and minor versions promise agreement on those cases.

The package remains below 1.0 while its public API is settling. The README carries
installation and usage examples, and the generated reference carries signatures.

## 0.8.0 - 2026-09-22

### Changed

- `Dialect.plainText(_:)` answers every case in the corpus as it did, and no longer
  parses a source that says nothing in markdown. The rules gained `marks`, the
  characters that can open a construct wherever they stand: a source carrying none
  of them, and not opening on a digit, which would number a list, is its own plain
  text. A caller stripping many short strings, most of which carry no markup, now
  reaches the parser only for the ones that do.
- The rules and the plain-text corpus were copied again from
  [the leading port](https://github.com/wikilayer/wlmarkdown), which adds the cases
  that hold the rule honest: a numbered or dashed line is still a list, an indented
  block is still code, and a setext underline is still a heading.

## 0.7.1 - 2026-09-18

### Changed

- Documented the complete public API and clarified the package boundary, setup,
  corpus relationship, and one parser limitation. Runtime behavior is unchanged.
- Updated commentcensor and removed release publication from the Makefile; releases
  are published through the repository workflow.

## 0.7.0 - 2026-09-16

### Added

- `Dialect.plainText(_:)` turns markdown into reader-visible text for search,
  previews and indexing, following the shared `plain_text.yaml` corpus.
- A generated Swift-DocC API reference, published through GitHub Pages.

## 0.6.0 - 2026-09-13

### Changed

- The corpus gained a `declined` key per case, naming what the dialect turned down,
  and new cases along with it. If you run the corpus yourself, a decoder that refuses
  unknown keys has to learn this one.
- The minor moves with [the leading port](https://github.com/wikilayer/wlmarkdown),
  which fixes two answers of its own for this release and adds `Kinds()`, a list of
  node kinds that only a host registering goldmark renderers has a use for. There is
  nothing to match here: this port hands back `Found` values, and `markers`,
  `classes` and `schemes` already name everything that can arrive in one.

  Between them these fixes close every difference the corpus can reach, and both
  ports now answer all of it alike. Matching major and minor said that much from
  0.4.0 on and were wrong to; what makes it true now is that the corpus asks about
  what was turned down as well.

### Fixed

- **Breaking for anyone counting what came back:** `declined(in:)` no longer reports
  a quote the dialect made an unreadable block of. Ask `unreadable(in:)` of the quote
  as well and you have what the old call gave you, with the two apart instead of run
  together.

  It answered about quotes `place(in:)` turned down, and since 0.5.0 that call also
  stays silent about a point nowhere on Earth — so a host logging or badging what was
  turned down complained about a block it had just drawn, and the leading port
  reported nothing for the same document. A host that only logs them needs no change
  and gets a quieter log.
- The words of an unreadable block are the whole quote's, not its first paragraph's.

  ```
  > [!MAP]
  > 999, 20
  >
  > The street I meant.
  ```

  `recognise` and `unreadable(in:)` handed back `[!MAP] 999, 20` and now hand back
  `[!MAP] 999, 20 The street I meant.` — one line, the quote's lines joined by a
  single space with every run of blanks squeezed to one, as the words of a callout
  have always been. Everything written below the coordinates was missing from the one
  place the author is shown what to fix. 0.5.0 said those words came back exactly as
  they stand in the source; a quote is now read whole, but its lines still arrive
  joined, so take that sentence as the markdown surviving rather than the layout.

  Markdown among them has always survived here, links included, so the other half of
  the leading port's fix for this release has no counterpart in this one.
- A callout no longer takes the words of a construct nested deeper than its own
  children. A map inside a list inside a callout left its marker and coordinates
  among the callout's words, so a host drawing that callout printed `[!MAP]` and a
  pair of numbers in the middle of a sentence, and drew the map underneath as well.
  The leading port has always answered this the other way.

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
