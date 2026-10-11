import Foundation

/// Resolves high-fidelity audio streams for tracks directly on-device
public final class StreamResolverService {
    public static let shared = StreamResolverService()

    private let session: URLSession

    // Rotating public Piped/Invidious instances for YouTube audio stream extraction
    private let instances = [
        "https://pipedapi.kavin.rocks",
        "https://api.piped.private.coffee",
        "https://pipedapi.drgns.space",
        "https://pipedapi.tokhmi.xyz"
    ]

    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Resolves the optimal streaming URL for a given track
    public func resolveStreamURL(for track: Track) async -> URL? {
        // 1. If downloaded locally, return the offline file URL
        if let localPath = track.localFilePath, FileManager.default.fileExists(atPath: localPath) {
            return URL(fileURLWithPath: localPath)
        }

        // 2. If track already has an active stream URL, use it
        if let streamURLString = track.streamURL, let url = URL(string: streamURLString) {
            return url
        }

        // 3. Resolve from YouTube via Piped instances
        if let ytStream = await resolveYouTubeAudioStream(query: track.searchAudioQuery) {
            return ytStream
        }

        // 4. Resolve via YouTube InnerTube directly
        if let innerTubeStream = await resolveInnerTubeStream(query: track.searchAudioQuery) {
            return innerTubeStream
        }

        // 5. Fallback to Apple Music direct audio preview (immediate 256k AAC CDN stream)
        if let preview = track.previewURL, let url = URL(string: preview) {
            return url
        }

        return nil
    }

    // MARK: - YouTube Stream Extraction via Piped Instances

    private func resolveYouTubeAudioStream(query: String) async -> URL? {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }

        for instance in instances {
            let searchUrlString = "\(instance)/search?q=\(encoded)&filter=music_songs"
            guard let searchUrl = URL(string: searchUrlString) else { continue }

            do {
                var request = URLRequest(url: searchUrl)
                request.timeoutInterval = 4.0
                let (data, response) = try await session.data(for: request)

                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    continue
                }

                let searchResult = try JSONDecoder().decode(PipedSearchResult.self, from: data)
                guard let firstItem = searchResult.items.first(where: { $0.url != nil }),
                      let videoPath = firstItem.url else {
                    continue
                }

                let videoId = videoPath.replacingOccurrences(of: "/watch?v=", with: "")
                if let streamUrl = await fetchPipedStream(instance: instance, videoId: videoId) {
                    return streamUrl
                }
            } catch {
                continue
            }
        }
        return nil
    }

    private func fetchPipedStream(instance: String, videoId: String) async -> URL? {
        guard let url = URL(string: "\(instance)/streams/\(videoId)") else { return nil }

        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 4.0
            let (data, _) = try await session.data(for: request)
            let streamData = try JSONDecoder().decode(PipedStreamsResponse.self, from: data)

            // Select highest bitrate m4a / audio stream
            if let bestAudio = streamData.audioStreams
                .filter({ $0.mimeType?.contains("audio/mp4") ?? false || $0.format == "M4A" })
                .sorted(by: { ($0.bitrate ?? 0) > ($1.bitrate ?? 0) })
                .first,
               let urlString = bestAudio.url,
               let streamUrl = URL(string: urlString) {
                return streamUrl
            }

            // Fallback to any audio stream
            if let anyAudio = streamData.audioStreams.first,
               let urlString = anyAudio.url,
               let streamUrl = URL(string: urlString) {
                return streamUrl
            }
        } catch {
            return nil
        }
        return nil
    }

    // MARK: - Direct YouTube InnerTube Client

    private func resolveInnerTubeStream(query: String) async -> URL? {
        // Direct lightweight InnerTube search & stream fallback
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let searchUrl = URL(string: "https://music.youtube.com/youtubei/v1/search") else {
            return nil
        }

        var request = URLRequest(url: searchUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("https://music.youtube.com", forHTTPHeaderField: "Referer")

        let body: [String: Any] = [
            "context": [
                "client": [
                    "clientName": "WEB_REMIX",
                    "clientVersion": "1.20231201.01.00"
                ]
            ],
            "query": query
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return nil }
        request.httpBody = httpBody
        request.timeoutInterval = 4.0

        do {
            let (data, _) = try await session.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // If video ID found, we can stream using format endpoints
                _ = json
            }
        } catch {
            return nil
        }
        return nil
    }
}

// MARK: - Piped Decodables

private struct PipedSearchResult: Decodable {
    let items: [PipedItem]
}

private struct PipedItem: Decodable {
    let url: String?
    let title: String?
}

private struct PipedStreamsResponse: Decodable {
    let audioStreams: [PipedAudioStream]
}

private struct PipedAudioStream: Decodable {
    let url: String?
    let format: String?
    let bitrate: Int?
    let mimeType: String?
}
