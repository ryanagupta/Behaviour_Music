import Foundation

/// Service for managing local library, favorites, playlists, and offline downloads
@Observable
public final class StorageService {
    public static let shared = StorageService()

    public var favoriteTracks: [Track] = []
    public var playlists: [Playlist] = []
    public var recentlyPlayed: [Track] = []
    public var downloadedTracks: [Track] = []
    public var downloadingTrackIds: Set<String> = []

    private let favoritesKey = "AppleMusic_Favorites"
    private let playlistsKey = "AppleMusic_Playlists"
    private let historyKey = "AppleMusic_RecentlyPlayed"
    private let downloadsKey = "AppleMusic_DownloadedTracks"

    private let fileManager = FileManager.default

    public init() {
        loadAll()
    }

    // MARK: - Persistence

    public func loadAll() {
        if let favData = UserDefaults.standard.data(forKey: favoritesKey),
           let tracks = try? JSONDecoder().decode([Track].self, from: favData) {
            self.favoriteTracks = tracks
        }

        if let playData = UserDefaults.standard.data(forKey: playlistsKey),
           let pl = try? JSONDecoder().decode([Playlist].self, from: playData) {
            self.playlists = pl
        } else {
            // Seed a starter user playlist
            self.playlists = [
                Playlist(title: "My Favorites", isUserCreated: true)
            ]
        }

        if let histData = UserDefaults.standard.data(forKey: historyKey),
           let rec = try? JSONDecoder().decode([Track].self, from: histData) {
            self.recentlyPlayed = rec
        } else {
            self.recentlyPlayed = Track.sampleList
        }

        if let downData = UserDefaults.standard.data(forKey: downloadsKey),
           let down = try? JSONDecoder().decode([Track].self, from: downData) {
            self.downloadedTracks = down
        }
    }

    public func saveAll() {
        if let favData = try? JSONEncoder().encode(favoriteTracks) {
            UserDefaults.standard.set(favData, forKey: favoritesKey)
        }
        if let playData = try? JSONEncoder().encode(playlists) {
            UserDefaults.standard.set(playData, forKey: playlistsKey)
        }
        if let histData = try? JSONEncoder().encode(recentlyPlayed) {
            UserDefaults.standard.set(histData, forKey: historyKey)
        }
        if let downData = try? JSONEncoder().encode(downloadedTracks) {
            UserDefaults.standard.set(downData, forKey: downloadsKey)
        }
    }

    // MARK: - Favorites

    public func toggleFavorite(track: Track) {
        if let index = favoriteTracks.firstIndex(where: { $0.id == track.id }) {
            favoriteTracks.remove(at: index)
        } else {
            var fav = track
            fav.isFavorite = true
            favoriteTracks.insert(fav, at: 0)
        }
        saveAll()
    }

    public func isFavorite(track: Track) -> Bool {
        favoriteTracks.contains(where: { $0.id == track.id })
    }

    // MARK: - History

    public func recordPlay(track: Track) {
        var updated = recentlyPlayed.filter { $0.id != track.id }
        updated.insert(track, at: 0)
        if updated.count > 40 {
            updated = Array(updated.prefix(40))
        }
        recentlyPlayed = updated
        saveAll()
    }

    // MARK: - Playlists

    public func createPlaylist(title: String, description: String? = nil) {
        let newPlaylist = Playlist(
            id: UUID().uuidString,
            title: title,
            curatorName: "Me",
            description: description,
            isUserCreated: true
        )
        playlists.append(newPlaylist)
        saveAll()
    }

    public func addTrack(_ track: Track, to playlistId: String) {
        if let index = playlists.firstIndex(where: { $0.id == playlistId }) {
            if !playlists[index].tracks.contains(where: { $0.id == track.id }) {
                playlists[index].tracks.append(track)
                saveAll()
            }
        }
    }

    // MARK: - Offline Downloads

    private var downloadsDirectory: URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("Downloads", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    public func downloadTrack(_ track: Track) async {
        guard !downloadingTrackIds.contains(track.id) else { return }
        downloadingTrackIds.insert(track.id)
        defer { downloadingTrackIds.remove(track.id) }

        // Resolve audio stream first
        guard let streamURL = await StreamResolverService.shared.resolveStreamURL(for: track) else {
            print("Could not resolve stream URL for download")
            return
        }

        let destination = downloadsDirectory.appendingPathComponent("\(track.id).m4a")

        do {
            let (data, _) = try await URLSession.shared.data(from: streamURL)
            try data.write(to: destination)

            var downloadedTrack = track
            downloadedTrack.isDownloaded = true
            downloadedTrack.localFilePath = destination.path

            downloadedTracks.removeAll(where: { $0.id == track.id })
            downloadedTracks.insert(downloadedTrack, at: 0)
            saveAll()
        } catch {
            print("Download failed for track \(track.title): \(error)")
        }
    }

    public func deleteDownload(track: Track) {
        if let path = track.localFilePath, fileManager.fileExists(atPath: path) {
            try? fileManager.removeItem(atPath: path)
        }
        downloadedTracks.removeAll(where: { $0.id == track.id })
        saveAll()
    }
}
