import Foundation
import UIKit

class StorageService {
    static let shared = StorageService()
    private init() {}
    
    // MARK: - Upload Single Image
    func uploadImage(
        _ image: UIImage,
        folder: String = "neighborrhub",
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(StorageError.compressionFailed))
            return
        }
        
        let urlString = "https://api.cloudinary.com/v1_1/dumfc0rv4/image/upload"
        guard let url = URL(string: urlString) else {
            completion(.failure(StorageError.invalidURL))
            return
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        
        var body = Data()
        
        // File
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Upload preset
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("neighborrhub_preset".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        // Folder
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"folder\"\r\n\r\n".data(using: .utf8)!)
        body.append(folder.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        print("📤 Uploading to Cloudinary...")
        print("📤 URL: \(urlString)")
        print("📤 Preset: neighborrhub_preset")
        print("📤 Image size: \(imageData.count) bytes")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 HTTP Status: \(httpResponse.statusCode)")
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    completion(.failure(StorageError.noData))
                    return
                }
                
                let responseString = String(data: data, encoding: .utf8) ?? "nil"
                print("📡 Cloudinary Response: \(responseString)")
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if let secureURL = json?["secure_url"] as? String {
                        print("✅ Upload Success: \(secureURL)")
                        completion(.success(secureURL))
                    } else if let errorMsg = json?["error"] as? [String: Any],
                              let msg = errorMsg["message"] as? String {
                        print("❌ Cloudinary Error: \(msg)")
                        completion(.failure(StorageError.cloudinaryError(msg)))
                    } else {
                        print("❌ Unknown response: \(responseString)")
                        completion(.failure(StorageError.unknown))
                    }
                } catch {
                    print("❌ JSON Parse Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // MARK: - Upload Multiple Images
    func uploadMultipleImages(
        _ images: [UIImage],
        folder: String = "neighborhub/posts",
        progressHandler: ((Int, Int) -> Void)? = nil,
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        var uploadedURLs: [String] = []
        var failedCount = 0
        let total = images.count
        
        guard total > 0 else {
            completion(.success([]))
            return
        }
        
        let group = DispatchGroup()
        
        for (index, image) in images.enumerated() {
            group.enter()
            
            uploadImage(image, folder: folder) { result in
                switch result {
                case .success(let url):
                    uploadedURLs.append(url)
                    progressHandler?(index + 1, total)
                case .failure:
                    failedCount += 1
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if uploadedURLs.isEmpty && failedCount > 0 {
                completion(.failure(StorageError.allUploadsFailed))
            } else {
                completion(.success(uploadedURLs))
            }
        }
    }
    
    // MARK: - Remove Image URL (Local)
    func removeImageURL(from urls: inout [String], url: String) {
        urls.removeAll { $0 == url }
    }
}

// MARK: - Storage Errors (ENGLISH ONLY)
enum StorageError: LocalizedError {
    case compressionFailed
    case fileTooLarge
    case invalidURL
    case noData
    case cloudinaryError(String)
    case allUploadsFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Image compression failed"
        case .fileTooLarge:
            return "Image size exceeds allowed limit"
        case .invalidURL:
            return "Invalid upload URL"
        case .noData:
            return "No response received from server"
        case .cloudinaryError(let msg):
            return msg
        case .allUploadsFailed:
            return "All image uploads failed"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}
