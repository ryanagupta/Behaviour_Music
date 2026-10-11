import Foundation

/// Represents a musical track within Apple Music
public struct Track: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let artistName: String
    public let albumName: String
    public let artworkURL: String?
    public let duration: TimeInterval
    public let releaseDate: String?
    public let genre: String?
    public let previewURL: String?
    public var streamURL: String?
    public let isExplicit: Bool
    public let trackNumber: Int?
    public var isFavorite: Bool
    public var isDownloaded: Bool
    public var localFilePath: String?

    public init(
        id: String,
        title: String,
        artistName: String,
        albumName: String,
        artworkURL: String? = nil,
        duration: TimeInterval = 0,
        releaseDate: String? = nil,
        genre: String? = nil,
        previewURL: String? = nil,
        streamURL: String? = nil,
        isExplicit: Bool = false,
        trackNumber: Int? = nil,
        isFavorite: Bool = false,
        isDownloaded: Bool = false,
        localFilePath: String? = nil
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.albumName = albumName
        self.artworkURL = artworkURL
        self.duration = duration
        self.releaseDate = releaseDate
        self.genre = genre
        self.previewURL = previewURL
        self.streamURL = streamURL
        self.isExplicit = isExplicit
        self.trackNumber = trackNumber
        self.isFavorite = isFavorite
        self.isDownloaded = isDownloaded
        self.localFilePath = localFilePath
    }

    /// Provides high-resolution Apple Music artwork by replacing thumbnail dimensions
    public func highResArtwork(size: Int = 1000) -> URL? {
        guard let artworkURL = artworkURL, !artworkURL.isEmpty else { return nil }
        // Standard iTunes artwork URLs have patterns like "100x100bb.jpg" or "{w}x{h}bb.jpg"
        let modified = artworkURL
            .replacingOccurrences(of: "{w}x{h}", with: "\(size)x\(size)")
            .replacingOccurrences(of: "100x100bb", with: "\(size)x\(size)bb")
            .replacingOccurrences(of: "60x60bb", with: "\(size)x\(size)bb")
            .replacingOccurrences(of: "200x200bb", with: "\(size)x\(size)bb")
        return URL(string: modified)
    }

    /// Formatted string like "3:42"
    public var formattedDuration: String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Formatted search query for audio stream lookup
    public var searchAudioQuery: String {
        "\(title) \(artistName) audio"
    }
}

// MARK: - Sample Previews for Mock & Offline States
extension Track {
    public static let sample = Track(
        id: "sample_blinding_lights",
        title: "Blinding Lights",
        artistName: "The Weeknd",
        albumName: "After Hours",
        artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/a5/15/d5/a515d5ec-ec94-2795-04b3-d64e9e03d360/20UMGIM08249.rgb.jpg/1000x1000bb.jpg",
        duration: 200,
        releaseDate: "2020",
        genre: "R&B/Soul",
        previewURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/44/e9/87/44e98774-8b63-021c-a337-1428254b0c79/mzaf_1508930491823906660.plus.aac.p.m4a",
        isExplicit: false,
        trackNumber: 9
    )

    public static let sampleList: [Track] = [
        sample,
        Track(
            id: "sample_starboy",
            title: "Starboy (feat. Daft Punk)",
            artistName: "The Weeknd",
            albumName: "Starboy",
            artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/f6/aa/ee/f6aaee5e-6eb9-64db-0a4a-f32a0c20a442/16UMGIM53229.rgb.jpg/1000x1000bb.jpg",
            duration: 230,
            genre: "R&B/Soul",
            isExplicit: true,
            trackNumber: 1
        ),
        Track(
            id: "sample_as_it_was",
            title: "As It Was",
            artistName: "Harry Styles",
            albumName: "Harry's House",
            artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/bc/93/bf/bc93bfa5-0be1-3ec7-8d01-ffebca33e8a3/886449942730.jpg/1000x1000bb.jpg",
            duration: 167,
            genre: "Pop",
            isExplicit: false,
            trackNumber: 4
        ),
        Track(
            id: "sample_cruel_summer",
            title: "Cruel Summer",
            artistName: "Taylor Swift",
            albumName: "Lover",
            artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/28/aa/a4/28aaa472-ee19-3d71-55bb-5926ec037ef6/19UMGIM68357.rgb.jpg/1000x1000bb.jpg",
            duration: 178,
            genre: "Pop",
            isExplicit: false,
            trackNumber: 2
        )
    ]
}
