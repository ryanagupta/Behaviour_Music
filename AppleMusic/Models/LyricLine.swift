import Foundation

/// Represents a single timestamped line of lyrics for synchronized karaoke display
public struct LyricLine: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let timestamp: TimeInterval
    public let text: String

    public init(id: UUID = UUID(), timestamp: TimeInterval, text: String) {
        self.id = id
        self.timestamp = timestamp
        self.text = text
    }
}

/// Structured collection of parsed lyrics (synced or plain)
public struct ParsedLyrics: Codable, Hashable, Sendable {
    public var lines: [LyricLine]
    public var plainLyrics: String?
    public var isSynced: Bool

    public init(lines: [LyricLine] = [], plainLyrics: String? = nil, isSynced: Bool = false) {
        self.lines = lines
        self.plainLyrics = plainLyrics
        self.isSynced = isSynced
    }

    /// Finds the index of the currently playing lyric line given playback time
    public func activeIndex(for time: TimeInterval) -> Int? {
        guard isSynced, !lines.isEmpty else { return nil }

        // Find the latest line whose timestamp is <= current playback time
        var bestIndex: Int? = nil
        for (index, line) in lines.enumerated() {
            if line.timestamp <= time {
                bestIndex = index
            } else {
                break
            }
        }
        return bestIndex
    }

    /// Parses an LRC formatted string (e.g. "[00:15.30] I've been on my own for long enough")
    public static func parse(lrc: String) -> ParsedLyrics {
        let rawLines = lrc.components(separatedBy: .newlines)
        var parsedLines: [LyricLine] = []

        // Regex for [mm:ss.xx] or [mm:ss]
        let pattern = #"\[(\d{1,2}):(\d{2})(?:\.(\d{1,3}))?\](.*)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return ParsedLyrics(plainLyrics: lrc, isSynced: false)
        }

        for rawLine in rawLines {
            let nsLine = rawLine as NSString
            let matches = regex.matches(in: rawLine, range: NSRange(location: 0, length: nsLine.length))
            for match in matches {
                guard match.numberOfRanges >= 5 else { continue }

                let minString = nsLine.substring(with: match.range(at: 1))
                let secString = nsLine.substring(with: match.range(at: 2))
                let msRange = match.range(at: 3)
                let textRange = match.range(at: 4)

                let minutes = Double(minString) ?? 0
                let seconds = Double(secString) ?? 0
                var fraction: Double = 0
                if msRange.location != NSNotFound {
                    let fracStr = nsLine.substring(with: msRange)
                    if fracStr.count == 2 {
                        fraction = (Double(fracStr) ?? 0) / 100.0
                    } else if fracStr.count == 3 {
                        fraction = (Double(fracStr) ?? 0) / 1000.0
                    }
                }

                let totalTime = (minutes * 60.0) + seconds + fraction
                let text = textRange.location != NSNotFound ? nsLine.substring(with: textRange).trimmingCharacters(in: .whitespaces) : ""

                if !text.isEmpty {
                    parsedLines.append(LyricLine(timestamp: totalTime, text: text))
                }
            }
        }

        parsedLines.sort { $0.timestamp < $1.timestamp }
        let isSynced = !parsedLines.isEmpty
        return ParsedLyrics(lines: parsedLines, plainLyrics: isSynced ? nil : lrc, isSynced: isSynced)
    }
}
