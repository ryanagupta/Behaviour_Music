import Foundation

/// Service for retrieving synchronized karaoke-style and plain lyrics via LRCLIB
@Observable
public final class LyricsService {
    public static let shared = LyricsService()

    public var currentLyrics: ParsedLyrics?
    public var isLoading: Bool = false
    public var errorMessage: String?

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetches time-synced lyrics for a track
    public func fetchLyrics(for track: Track) async {
        isLoading = true
        errorMessage = nil
        currentLyrics = nil
        defer { isLoading = false }

        // Attempt 1: Exact match query
        if let lyrics = await fetchExactLyrics(track: track) {
            self.currentLyrics = lyrics
            return
        }

        // Attempt 2: Search query fallback
        if let lyrics = await searchLyrics(track: track) {
            self.currentLyrics = lyrics
            return
        }

        self.errorMessage = "No lyrics available for this song."
    }

    private func fetchExactLyrics(track: Track) async -> ParsedLyrics? {
        var components = URLComponents(string: "https://lrclib.net/api/get")
        components?.queryItems = [
            URLQueryItem(name: "track_name", value: track.title),
            URLQueryItem(name: "artist_name", value: track.artistName),
            URLQueryItem(name: "album_name", value: track.albumName),
            URLQueryItem(name: "duration", value: "\(Int(track.duration))")
        ]

        guard let url = components?.url else { return nil }

        do {
            var request = URLRequest(url: url)
            request.setValue("AppleMusicClone/1.0", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 4.0
            let (data, response) = try await session.data(for: request)

            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return nil
            }

            let result = try JSONDecoder().decode(LRCLIBResponse.self, from: data)
            if let synced = result.syncedLyrics, !synced.isEmpty {
                return ParsedLyrics.parse(lrc: synced)
            } else if let plain = result.plainLyrics, !plain.isEmpty {
                return ParsedLyrics(plainLyrics: plain, isSynced: false)
            }
        } catch {
            return nil
        }
        return nil
    }

    private func searchLyrics(track: Track) async -> ParsedLyrics? {
        let query = "\(track.title) \(track.artistName)"
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://lrclib.net/api/search?q=\(encoded)") else {
            return nil
        }

        do {
            var request = URLRequest(url: url)
            request.setValue("AppleMusicClone/1.0", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 4.0
            let (data, response) = try await session.data(for: request)

            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return nil
            }

            let results = try JSONDecoder().decode([LRCLIBResponse].self, from: data)
            // Pick first result that has synced lyrics
            if let best = results.first(where: { $0.syncedLyrics != nil && !($0.syncedLyrics?.isEmpty ?? true) }),
               let synced = best.syncedLyrics {
                return ParsedLyrics.parse(lrc: synced)
            }

            // Fallback to first plain lyrics
            if let first = results.first(where: { $0.plainLyrics != nil }),
               let plain = first.plainLyrics {
                return ParsedLyrics(plainLyrics: plain, isSynced: false)
            }
        } catch {
            return nil
        }
        return nil
    }
}

// MARK: - LRCLIB API Decodable
private struct LRCLIBResponse: Decodable {
    let id: Int?
    let trackName: String?
    let artistName: String?
    let albumName: String?
    let duration: Double?
    let instrumental: Bool?
    let plainLyrics: String?
    let syncedLyrics: String?
}
