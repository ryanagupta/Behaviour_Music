import Foundation

/// Represents an album in Apple Music
public struct Album: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let artistName: String
    public let artworkURL: String?
    public let releaseYear: String?
    public let genre: String?
    public var tracks: [Track]
    public let copyright: String?

    public init(
        id: String,
        name: String,
        artistName: String,
        artworkURL: String? = nil,
        releaseYear: String? = nil,
        genre: String? = nil,
        tracks: [Track] = [],
        copyright: String? = nil
    ) {
        self.id = id
        self.name = name
        self.artistName = artistName
        self.artworkURL = artworkURL
        self.releaseYear = releaseYear
        self.genre = genre
        self.tracks = tracks
        self.copyright = copyright
    }

    public func highResArtwork(size: Int = 1000) -> URL? {
        guard let artworkURL = artworkURL, !artworkURL.isEmpty else { return nil }
        let modified = artworkURL
            .replacingOccurrences(of: "{w}x{h}", with: "\(size)x\(size)")
            .replacingOccurrences(of: "100x100bb", with: "\(size)x\(size)bb")
            .replacingOccurrences(of: "60x60bb", with: "\(size)x\(size)bb")
            .replacingOccurrences(of: "200x200bb", with: "\(size)x\(size)bb")
        return URL(string: modified)
    }
}

extension Album {
    /// Replicates The Weeknd's "Hurry Up Tomorrow" album from Image 1
    public static let hurryUpTomorrow = Album(
        id: "album_hurry_up_tomorrow",
        name: "Hurry Up Tomorrow",
        artistName: "The Weeknd",
        artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/09/a2/bf/09a2bfbb-1bfd-c4dc-9477-980590a2be25/24UMGIM86307.rgb.jpg/1000x1000bb.jpg",
        releaseYear: "2025",
        genre: "R&B/Soul",
        tracks: [
            Track(id: "hut_1", title: "Wake Me Up", artistName: "The Weeknd & Justice", albumName: "Hurry Up Tomorrow", duration: 234, trackNumber: 1),
            Track(id: "hut_2", title: "Cry For Me", artistName: "The Weeknd", albumName: "Hurry Up Tomorrow", duration: 221, isExplicit: true, trackNumber: 2),
            Track(id: "hut_3", title: "São Paulo (feat. Anitta)", artistName: "The Weeknd", albumName: "Hurry Up Tomorrow", duration: 181, isExplicit: true, trackNumber: 3),
            Track(id: "hut_4", title: "Timeless (feat. Playboi Carti)", artistName: "The Weeknd", albumName: "Hurry Up Tomorrow", duration: 256, isExplicit: true, trackNumber: 4),
            Track(id: "hut_5", title: "Dancing In The Flames", artistName: "The Weeknd", albumName: "Hurry Up Tomorrow", duration: 220, trackNumber: 5)
        ],
        copyright: "℗ 2025 The Weeknd XO, Inc., manufactured and marketed by Republic Records, a division of UMG Recordings, Inc."
    )

    /// Replicates SZA's "SOS" album from Image 2
    public static let szaSOS = Album(
        id: "album_sza_sos",
        name: "SOS",
        artistName: "SZA",
        artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/80/7e/c4/807ec4d6-8485-de0f-b258-052062569bb2/196589578132.jpg/1000x1000bb.jpg",
        releaseYear: "2022",
        genre: "R&B/Soul",
        tracks: [
            Track(id: "sos_1", title: "SOS", artistName: "SZA", albumName: "SOS", duration: 124, isExplicit: true, trackNumber: 1),
            Track(id: "sos_2", title: "Kill Bill", artistName: "SZA", albumName: "SOS", duration: 153, isExplicit: true, trackNumber: 2),
            Track(id: "sos_3", title: "Seek & Destroy", artistName: "SZA", albumName: "SOS", duration: 203, isExplicit: true, trackNumber: 3),
            Track(id: "sos_4", title: "Snooze", artistName: "SZA", albumName: "SOS", duration: 201, isExplicit: true, trackNumber: 4)
        ],
        copyright: "℗ 2022 Top Dawg Entertainment, under exclusive license to RCA Records"
    )

    public static let sample = hurryUpTomorrow
}
