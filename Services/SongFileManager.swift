import Foundation
import AVFoundation

/// Dosya sistemi ile ilgili tüm işlemleri izole eden servis.
/// ViewModel'ler bu servisi kullanır, UI hiçbir zaman doğrudan FileManager'a dokunmaz.
final class SongFileManager {

    static let shared = SongFileManager()
    private init() {}

    /// "Documents/BenimŞarkılarım" klasörünün URL'i.
    /// Klasör yoksa otomatik oluşturulur.
    lazy var musicFolderURL: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory,
                                                   in: .userDomainMask)[0]
        let musicFolder = documents.appendingPathComponent("BenimŞarkılarım", isDirectory: true)

        if !FileManager.default.fileExists(atPath: musicFolder.path) {
            try? FileManager.default.createDirectory(at: musicFolder,
                                                       withIntermediateDirectories: true)
        }
        return musicFolder
    }()

    /// Klasördeki tüm mp3 dosyalarını tarar ve Song modeline çevirir.
    func loadSongs() -> [Song] {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: musicFolderURL,
            includingPropertiesForKeys: nil
        ) else { return [] }

        let mp3Files = files.filter { $0.pathExtension.lowercased() == "mp3" }

        let songs = mp3Files.map { url -> Song in
            let title = url.deletingPathExtension().lastPathComponent
            let duration = getDuration(for: url)
            return Song(id: url.lastPathComponent, title: title, fileURL: url, duration: duration)
        }

        // Alfabetik sıralama (Türkçe karakter uyumlu)
        return songs.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }

    /// AVAsset üzerinden şarkı süresini hesaplar.
    private func getDuration(for url: URL) -> TimeInterval {
        let asset = AVURLAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }
}
