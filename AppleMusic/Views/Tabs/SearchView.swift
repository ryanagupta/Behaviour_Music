import SwiftUI

public enum SearchScope: String, CaseIterable {
    case appleMusic = "Apple Music"
    case library = "Library"
}

/// 1-to-1 Apple Music Search View matching Image 4 & Image 5
public struct SearchView: View {
    @State private var catalog = AppleCatalogService.shared
    @State private var storage = StorageService.shared
    @State private var audio = AudioPlayerService.shared

    @State private var searchText = ""
    @State private var isSearchingActive = false
    @State private var selectedScope: SearchScope = .appleMusic
    @State private var searchTask: Task<Void, Never>? = nil

    @FocusState private var isSearchFocused: Bool

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Apple Music Search Bar with Mic & Cancel Button (Image 4 & 5)
                searchHeader

                // Segmented Scope Bar [ Apple Music | Library ] when search is active (Image 5)
                if isSearchingActive || !searchText.isEmpty {
                    scopeBar
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Main content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if searchText.isEmpty && !isSearchingActive {
                            // Category Grid matching Image 4
                            categoriesGrid
                        } else if !searchText.isEmpty {
                            // Active Search Suggestions & Live Results matching Image 5
                            activeSearchResults
                        } else {
                            // Empty active search state
                            Text("Search for artists, songs, and albums in \(selectedScope.rawValue).")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        }

                        // Bottom padding for mini-player and floating tab bar
                        Spacer().frame(height: 120)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle(isSearchingActive ? "" : "Search")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.black.ignoresSafeArea())
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Search Header (Image 4 & 5)

    private var searchHeader: some View {
        HStack(spacing: 10) {
            // Search Input Pill
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)

                TextField("Artists, Songs, Lyrics and More", text: $searchText)
                    .focused($isSearchFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .foregroundStyle(.white)
                    .font(.system(size: 16))
                    .onChange(of: searchText) { _, newValue in
                        handleSearchChange(newValue)
                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        catalog.searchResults = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Color(white: 0.16))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            // Cancel Button (Red text, visible when focused)
            if isSearchingActive || isSearchFocused || !searchText.isEmpty {
                Button("Cancel") {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        searchText = ""
                        isSearchingActive = false
                        isSearchFocused = false
                        catalog.searchResults = []
                    }
                }
                .foregroundStyle(AppleMusicTheme.accent)
                .font(.system(size: 16))
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onTapGesture {
            isSearchingActive = true
        }
    }

    // MARK: - Scope Bar (Image 5)

    private var scopeBar: some View {
        HStack(spacing: 0) {
            ForEach(SearchScope.allCases, id: \.self) { scope in
                let isSelected = (selectedScope == scope)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedScope = scope
                    }
                } label: {
                    Text(scope.rawValue)
                        .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .fill(isSelected ? Color(white: 0.3) : Color.clear)
                        )
                }
            }
        }
        .padding(3)
        .background(Color(white: 0.14))
        .clipShape(RoundedRectangle(cornerRadius: 9))
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }

    // MARK: - Categories Grid (Image 4)

    private var categoriesGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(BrowseCategoryItem.samples) { item in
                    Button {
                        searchText = item.title
                        isSearchingActive = true
                        performSearch(term: item.title)
                    } label: {
                        CategoryPhotoCard(item: item)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Active Search Suggestions & Results (Image 5)

    private var activeSearchResults: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Auto-complete suggestions (Image 5)
            ForEach(catalog.searchSuggestions.prefix(3), id: \.self) { suggestion in
                Button {
                    searchText = suggestion
                    performSearch(term: suggestion)
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)

                        Text(suggestion)
                            .font(.system(size: 17))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }

                Divider()
                    .background(Color(white: 0.2))
                    .padding(.leading, 48)
            }

            // Results List (Songs and Albums matching Image 5)
            if selectedScope == .appleMusic {
                // Songs
                ForEach(catalog.searchResults) { track in
                    HStack(spacing: 12) {
                        ArtworkImageView(url: track.highResArtwork(size: 140), cornerRadius: 4, shadowRadius: 0)
                            .frame(width: 48, height: 48)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(track.title)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            Text("Song • \(track.artistName)")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        Image(systemName: "ellipsis")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        audio.playTrack(track, in: catalog.searchResults)
                    }

                    Divider()
                        .background(Color(white: 0.18))
                        .padding(.leading, 72)
                }

                // Albums
                ForEach(catalog.searchAlbums) { album in
                    NavigationLink {
                        AlbumDetailView(album: album)
                    } label: {
                        HStack(spacing: 12) {
                            ArtworkImageView(url: album.highResArtwork(size: 140), cornerRadius: 4, shadowRadius: 0)
                                .frame(width: 48, height: 48)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(album.name)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)

                                Text("Album • \(album.artistName)")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }

                    Divider()
                        .background(Color(white: 0.18))
                        .padding(.leading, 72)
                }
            } else {
                // Library results
                let filteredFavorites = storage.favoriteTracks.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText) ||
                    $0.artistName.localizedCaseInsensitiveContains(searchText)
                }

                if filteredFavorites.isEmpty {
                    Text("No results found in your Library.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(20)
                } else {
                    ForEach(filteredFavorites) { track in
                        TrackRowView(track: track) {
                            audio.playTrack(track, in: filteredFavorites)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)

                        Divider().padding(.leading, 72)
                    }
                }
            }
        }
    }

    private func handleSearchChange(_ query: String) {
        searchTask?.cancel()
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            catalog.searchResults = []
            catalog.searchAlbums = []
        } else {
            searchTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                guard !Task.isCancelled else { return }
                await catalog.search(term: query)
            }
        }
    }

    private func performSearch(term: String) {
        Task {
            await catalog.search(term: term)
        }
    }
}

// MARK: - Browse Category Data (Matching Image 4)

public struct BrowseCategoryItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let gradient: LinearGradient
    public let secondaryColor: Color

    public static let samples: [BrowseCategoryItem] = [
        BrowseCategoryItem(title: "HEAD TRIP", gradient: LinearGradient(colors: [Color(hex: "#FF4E50"), Color(hex: "#F9D423")], startPoint: .topLeading, endPoint: .bottomTrailing), secondaryColor: Color(hex: "#A83279")),
        BrowseCategoryItem(title: "Hits", gradient: LinearGradient(colors: [Color(hex: "#F7971E"), Color(hex: "#FFD200")], startPoint: .topLeading, endPoint: .bottomTrailing), secondaryColor: .orange),
        BrowseCategoryItem(title: "Pop", gradient: LinearGradient(colors: [Color(hex: "#FF416C"), Color(hex: "#FF4B2B")], startPoint: .topLeading, endPoint: .bottomTrailing), secondaryColor: .pink),
        BrowseCategoryItem(title: "Hip-Hop", gradient: LinearGradient(colors: [Color(hex: "#4E54C8"), Color(hex: "#8F94FB")], startPoint: .topLeading, endPoint: .bottomTrailing), secondaryColor: .blue),
        BrowseCategoryItem(title: "Dance", gradient: LinearGradient(colors: [Color(hex: "#11998E"), Color(hex: "#38EF7D")], startPoint: .topLeading, endPoint: .bottomTrailing), secondaryColor: .green),
        BrowseCategoryItem(title: "Alternative", gradient: LinearGradient(colors: [Color(hex: "#F2994A"), Color(hex: "#F2C94C")], startPoint: .topLeading, endPoint: .bottomTrailing), secondaryColor: .yellow),
        BrowseCategoryItem(title: "R&B/Soul", gradient: LinearGradient(colors: [Color(hex: "#654ea3"), Color(hex: "#eaafc8")], startPoint: .topLeading, endPoint: .bottomTrailing), secondaryColor: .purple),
        BrowseCategoryItem(title: "Country", gradient: LinearGradient(colors: [Color(hex: "#D38312"), Color(hex: "#A83279")], startPoint: .topLeading, endPoint: .bottomTrailing), secondaryColor: .brown),
        BrowseCategoryItem(title: "Rock", gradient: LinearGradient(colors: [Color(hex: "#232526"), Color(hex: "#414345")], startPoint: .topLeading, endPoint: .bottomTrailing), secondaryColor: .gray),
        BrowseCategoryItem(title: "Chill", gradient: LinearGradient(colors: [Color(hex: "#00c6ff"), Color(hex: "#0072ff")], startPoint: .topLeading, endPoint: .bottomTrailing), secondaryColor: .teal)
    ]
}

/// Category Card replicating the visual appearance of Image 4
private struct CategoryPhotoCard: View {
    let item: BrowseCategoryItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(item.gradient)
                .frame(height: 104)

            // Stylized background iconography to mirror the artist silhouettes
            HStack {
                Spacer()
                Image(systemName: "music.note")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(.white.opacity(0.18))
                    .rotationEffect(.degrees(-15))
                    .offset(x: 10, y: 15)
            }

            // Category Title
            Text(item.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .padding(12)
        }
        .frame(height: 104)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
    }
}
