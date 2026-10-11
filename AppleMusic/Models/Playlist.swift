import Foundation

/// Represents a playlist, either curated by Apple or created by the user
public struct Playlist: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public var title: String
    public var curatorName: String
    public var description: String?
    public var artworkURL: String?
    public var tracks: [Track]
    public var isUserCreated: Bool

    public init(
        id: String = UUID().uuidString,
        title: String,
        curatorName: String = "Apple Music",
        description: String? = nil,
        artworkURL: String? = nil,
        tracks: [Track] = [],
        isUserCreated: Bool = false
    ) {
        self.id = id
        self.title = title
        self.curatorName = curatorName
        self.description = description
        self.artworkURL = artworkURL
        self.tracks = tracks
        self.isUserCreated = isUserCreated
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

extension Playlist {
    public static let sampleCurated: [Playlist] = [
        Playlist(
            id: "curated_todays_hits",
            title: "Today's Hits",
            curatorName: "Apple Music Pop",
            description: "The biggest songs right now, updated constantly.",
            artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Features125/v4/a5/b3/ef/a5b3ef31-5264-b25f-2c7c-48be0e5137ce/U01GX01FLVNULTA0MzgtVG9kYXlzX0hpdHNDb3Zlci0yMDIzLnBuZw.png/1000x1000bb.jpg",
            tracks: Track.sampleList
        ),
        Playlist(
            id: "curated_chill_mix",
            title: "Chill Mix",
            curatorName: "Apple Music",
            description: "Mellow grooves and relaxed rhythms to soundtrack your downtime.",
            artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Features115/v4/e5/bd/fa/e5bdfa49-9f20-fa40-5a3d-a5d625fc9e51/U01GX01FLVNULTAzMzktQ2hpbGxfTWl4Q292ZXItMjAyMy5wbmc.png/1000x1000bb.jpg",
            tracks: Track.sampleList
        ),
        Playlist(
            id: "curated_top_100",
            title: "Top 100: Global",
            curatorName: "Apple Music",
            description: "The 100 most played tracks in the world right now.",
            artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Features124/v4/d9/39/3a/d9393a52-c322-2ba6-4556-9a2df4c7b8e5/U01GX01FLVNULTAzMjktR2xvYmFsVG9wMTAwQ292ZXItMjAyMy5wbmc.png/1000x1000bb.jpg",
            tracks: Track.sampleList
        )
    ]
}
