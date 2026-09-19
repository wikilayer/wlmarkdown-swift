import Foundation
import Markdown

struct Scan {
  let dialect: Dialect
  let lines: [String]

  init(dialect: Dialect, source: String) {
    self.dialect = dialect
    lines = source.components(separatedBy: "\n")
  }

  func raw(from: SourceLocation, to ending: SourceLocation) -> String {
    guard from.line == ending.line, from.line >= 1, from.line <= lines.count else {
      return ""
    }
    let held = lines[from.line - 1]
    guard let start = held.index(atColumn: from.column),
      let end = held.index(atColumn: ending.column),
      start <= end
    else {
      return ""
    }
    return String(held[start..<end])
  }

  static let tabStop = 4

  func rawLines(of paragraph: Paragraph) -> [String] {
    var written: [String] = []
    var line: [any InlineMarkup] = []

    func close() {
      let ranged = line.compactMap { inline -> (SourceLocation, SourceLocation)? in
        guard let range = inline.range else { return nil }
        return (range.lowerBound, range.upperBound)
      }
      let parsed = line.map { dialect.words(of: $0) }.joined()
      guard let first = ranged.first, let last = ranged.last else {
        written.append(parsed)
        return
      }
      let spelled = raw(from: first.0, to: last.1)
      let asWide = last.1.column - first.0.column
      written.append(spelled.utf8.count == asWide ? spelled : parsed)
    }

    for inline in paragraph.inlineChildren {
      if inline is SoftBreak || inline is LineBreak {
        close()
        line = []
        continue
      }
      line.append(inline)
    }
    close()
    return written
  }

  func inlineLines(of paragraph: Paragraph) -> [[any InlineMarkup]] {
    var written: [[any InlineMarkup]] = []
    var line: [any InlineMarkup] = []
    for inline in paragraph.inlineChildren {
      if inline is SoftBreak || inline is LineBreak {
        written.append(line)
        line = []
        continue
      }
      line.append(inline)
    }
    written.append(line)
    return written
  }

  func isAutolink(_ link: Markdown.Link) -> Bool {
    guard let range = link.range else { return false }
    return raw(from: range.lowerBound, to: range.upperBound).hasPrefix("<")
  }
}

extension String {
  func index(atColumn column: Int) -> String.Index? {
    var counted = 1
    var walked = startIndex
    while counted < column, walked < endIndex {
      let letter = self[walked]
      counted +=
        letter == "\t"
        ? Scan.tabStop - (counted - 1) % Scan.tabStop
        : letter.utf8.count
      walked = index(after: walked)
    }
    return counted == column ? walked : nil
  }
}
