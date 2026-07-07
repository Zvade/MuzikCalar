import SwiftUI

/// "Benim Şarkılarım" klasöründeki tüm mp3'leri arama çubuğuyla birlikte listeler.
struct SongListView: View {
    @ObservedObject var library: SongLibraryViewModel
    @ObservedObject var player: AudioPlayerViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if library.filteredSongs.isEmpty {
                    emptyStateView
                } else {
                    songList
                }
            }
            .navigationTitle("Benim Şarkılarım")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $library.searchText, prompt: "Şarkı ara")
            .refreshable {
                library.refresh()
            }
        }
        .preferredColorScheme(.dark)
    }

    private var songList: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(library.filteredSongs) { song in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            player.setQueue(library.filteredSongs, startAt: song)
                            player.isNowPlayingPresented = true
                        }
                    } label: {
                        SongRowView(
                            song: song,
                            isCurrent: player.currentSong == song,
                            isPlaying: player.isPlaying
                        )
                    }
                    .pressableStyle(scale: 0.97)
                    // Liste elemanlarının belirişi için hafif geçiş animasyonu
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            // Mini player'ın listenin altını kapatmaması için boşluk
            .padding(.bottom, player.currentSong != nil ? 90 : 20)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 56))
                .foregroundStyle(Color.textSecondary)

            Text("Henüz şarkı yok")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text("Dosyalar uygulamasından \"Benim Şarkılarım\" klasörüne mp3 dosyalarını ekleyin.")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                library.refresh()
            } label: {
                Text("Yenile")
                    .font(.subheadline.bold())
                    .foregroundStyle(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.spotifyGreen))
            }
            .pressableStyle()
            .padding(.top, 8)
        }
        .padding()
    }
}
