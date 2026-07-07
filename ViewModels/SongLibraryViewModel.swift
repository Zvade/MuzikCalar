import Foundation
import Combine

@MainActor
final class SongLibraryViewModel: ObservableObject {

    @Published private(set) var allSongs: [Song] = []
    @Published var searchText: String = ""

    /// Aranan metne göre filtrelenmiş liste.
    var filteredSongs: [Song] {
        guard !searchText.isEmpty else { return allSongs }
        return allSongs.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    init() {
        refresh()
    }

    /// Klasörü yeniden tarar (pull-to-refresh veya uygulama açılışında çağrılır).
    func refresh() {
        withAnimation {
            allSongs = SongFileManager.shared.loadSongs()
        }
    }

    private func withAnimation(_ block: () -> Void) {
        block()
    }
}
