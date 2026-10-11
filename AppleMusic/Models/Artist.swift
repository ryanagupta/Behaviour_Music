import Foundation

/// Represents an artist in Apple Music
public struct Artist: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let genre: String?
    public let artworkURL: String?
    public var topTracks: [Track]
    public var albums: [Album]
    public let bio: String?

    public init(
        id: String,
        name: String,
        genre: String? = nil,
        artworkURL: String? = nil,
        topTracks: [Track] = [],
        albums: [Album] = [],
        bio: String? = nil
    ) {
        self.id = id
        self.name = name
        self.genre = genre
        self.artworkURL = artworkURL
        self.topTracks = topTracks
        self.albums = albums
        self.bio = bio
    }
}
