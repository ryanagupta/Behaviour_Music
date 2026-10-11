import Foundation

/// Service for fetching official Apple Music catalog, search results, suggestions, and top charts
@Observable
public final class AppleCatalogService {
    public static let shared = AppleCatalogService()

    public var topSongs: [Track] = []
    public var featuredPlaylists: [Playlist] = Playlist.sampleCurated
    public var searchResults: [Track] = []
    public var searchAlbums: [Album] = []
    public var searchSuggestions: [String] = []
    public var isSearching: Bool = false
    public var isLoadingCharts: Bool = false

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Top Charts via Official Apple RSS Feeds

    public func fetchTopCharts(limit: Int = 50) async {
        guard !isLoadingCharts else { return }
        isLoadingCharts = true
        defer { isLoadingCharts = false }

        let urlString = "https://rss.applemarketingtools.com/api/v2/us/music/most-played/\(limit)/songs.json"
        guard let url = URL(string: urlString) else {
            self.topSongs = Track.sampleList
            return
        }

        do {
            let (data, _) = try await session.data(from: url)
            let feedResponse = try JSONDecoder().decode(RSSFeedResponse.self, from: data)

            let tracks = feedResponse.feed.results.enumerated().map { index, item in
                Track(
                    id: item.id,
                    title: item.name,
                    artistName: item.artistName,
                    albumName: item.name,
                    artworkURL: item.artworkUrl100,
                    duration: 210,
                    releaseDate: item.releaseDate,
                    genre: item.genres?.first?.name ?? "Music",
                    previewURL: nil,
                    trackNumber: index + 1
                )
            }

            if !tracks.isEmpty {
                self.topSongs = tracks
            } else {
                self.topSongs = Track.sampleList
            }
        } catch {
            print("Apple RSS chart fetch failed, using fallback tracks: \(error)")
            if self.topSongs.isEmpty {
                self.topSongs = Track.sampleList
            }
        }
    }

    // MARK: - Search via Official iTunes Store Search API

    public func search(term: String) async {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            self.searchResults = []
            self.searchAlbums = []
            self.searchSuggestions = []
            return
        }

        isSearching = true
        defer { isSearching = false }

        // Generate dynamic search suggestions matching Image 5
        self.generateSuggestions(for: trimmed)

        guard let encodedTerm = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://itunes.apple.com/search?term=\(encodedTerm)&entity=song&limit=30") else {
            return
        }

        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(ITunesSearchResponse.self, from: data)

            var songs: [Track] = []
            var albumMap: [String: Album] = [:]

            for result in response.results {
                let track = Track(
                    id: "\(result.trackId ?? Int.random(in: 1000...999999))",
                    title: result.trackName ?? "Unknown Track",
                    artistName: result.artistName ?? "Unknown Artist",
                    albumName: result.collectionName ?? "Single",
                    artworkURL: result.artworkUrl100,
                    duration: TimeInterval((result.trackTimeMillis ?? 180000) / 1000),
                    releaseDate: result.releaseDate,
                    genre: result.primaryGenreName,
                    previewURL: result.previewUrl,
                    isExplicit: result.trackExplicitness == "explicit",
                    trackNumber: result.trackNumber
                )
                songs.append(track)

                if let collectionId = result.collectionId, let collectionName = result.collectionName {
                    let albumId = "\(collectionId)"
                    if albumMap[albumId] == nil {
                        albumMap[albumId] = Album(
                            id: albumId,
                            name: collectionName,
                            artistName: result.artistName ?? "",
                            artworkURL: result.artworkUrl100,
                            releaseYear: result.releaseDate,
                            genre: result.primaryGenreName,
                            tracks: [track]
                        )
                    } else {
                        albumMap[albumId]?.tracks.append(track)
                    }
                }
            }

            self.searchResults = songs
            self.searchAlbums = Array(albumMap.values)

            // Add top track titles to suggestions if available
            let trackTitles = Array(songs.prefix(3).map { $0.title })
            for title in trackTitles {
                if !self.searchSuggestions.contains(title) {
                    self.searchSuggestions.insert(title, at: 0)
                }
            }
        } catch {
            print("Search failed: \(error)")
        }
    }

    private func generateSuggestions(for term: String) {
        let base = term.lowercased()
        self.searchSuggestions = [
            "\(base) lyrics",
            "\(base) album",
            "\(base) live",
            "\(base) remix"
        ]
    }

    public func fetchAlbumTracks(albumId: String) async -> [Track] {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(albumId)&entity=song") else {
            return []
        }

        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(ITunesSearchResponse.self, from: data)
            return response.results.compactMap { res in
                guard res.wrapperType == "track" || res.trackName != nil else { return nil }
                return Track(
                    id: "\(res.trackId ?? Int.random(in: 1000...999999))",
                    title: res.trackName ?? "Unknown",
                    artistName: res.artistName ?? "Unknown Artist",
                    albumName: res.collectionName ?? "",
                    artworkURL: res.artworkUrl100,
                    duration: TimeInterval((res.trackTimeMillis ?? 180000) / 1000),
                    releaseDate: res.releaseDate,
                    genre: res.primaryGenreName,
                    previewURL: res.previewUrl,
                    isExplicit: res.trackExplicitness == "explicit",
                    trackNumber: res.trackNumber
                )
            }
        } catch {
            print("Failed to fetch album tracks: \(error)")
            return []
        }
    }
}

// MARK: - Decodables

private struct RSSFeedResponse: Decodable {
    let feed: RSSFeed
}

private struct RSSFeed: Decodable {
    let results: [RSSItem]
}

private struct RSSItem: Decodable {
    let id: String
    let name: String
    let artistName: String
    let artworkUrl100: String?
    let releaseDate: String?
    let genres: [RSSGenre]?
}

private struct RSSGenre: Decodable {
    let name: String
}

private struct ITunesSearchResponse: Decodable {
    let resultCount: Int
    let results: [ITunesItem]
}

private struct ITunesItem: Decodable {
    let wrapperType: String?
    let trackId: Int?
    let trackName: String?
    let artistName: String?
    let collectionId: Int?
    let collectionName: String?
    let artworkUrl100: String?
    let trackTimeMillis: Int?
    let releaseDate: String?
    let primaryGenreName: String?
    let previewUrl: String?
    let trackExplicitness: String?
    let trackNumber: Int?
}
