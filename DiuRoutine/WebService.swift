import Foundation
import SwiftData
import Combine

enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse
    case badStatus
    case failedToDecodeResponse
}


class RoutineVersionStore: ObservableObject {
    @Published var routineVersion: String {
        didSet {
            UserDefaults.standard.set(routineVersion, forKey: "routineVersion")
        }
    }
    
    @Published var inMaintenance: Bool {
        didSet {
            UserDefaults.standard.set(inMaintenance, forKey: "inMaintenance")
        }
    }
    
    init() {
        self.routineVersion = UserDefaults.standard.string(forKey: "routineVersion") ?? ""
        self.inMaintenance = UserDefaults.standard.bool(forKey: "inMaintenance")
    }
    
    func clearData() {
        routineVersion = ""
        UserDefaults.standard.removeObject(forKey: "routineVersion")
    }
}


class WebService {
    @MainActor
    func fetchVersion(
        versionStore: RoutineVersionStore,
        modelContext: ModelContext
    ) async {
        do {
            let versionResponse: VersionResponse = try await fetchSingleData(fromUrl: "https://diu.zahidp.xyz/api/version")
            
                // ✅ Always update inMaintenance
            versionStore.inMaintenance = versionResponse.data.inMaintenance
            
                // ✅ Then handle version update
            if versionResponse.data.version != versionStore.routineVersion {
                print("New version detected! Updating database...")
                
                    // ✅ Only update version if database update succeeds
                let success = await updateDataInDatabase(modelContext: modelContext)
                
                if success {
                    versionStore.routineVersion = versionResponse.data.version
                    print("Version updated to: \(versionResponse.data.version)")
                } else {
                        // ⚠️ Database update failed - reset version
                    versionStore.routineVersion = ""
                    print("Database update failed. Version reset to empty.")
                }
            } else {
                print("Version is the same. No update needed.")
            }
            
        } catch {
            print("Failed to fetch version: \(error)")
        }
    }
    
    private func clearAllData(modelContext: ModelContext) async throws {
        do {
                // Delete all RoutineDO objects
            let fetchDescriptor = FetchDescriptor<RoutineDO>()
            let existingItems = try modelContext.fetch(fetchDescriptor)
            
            for item in existingItems {
                modelContext.delete(item)
            }
            
            try modelContext.save()
            print("Cleared \(existingItems.count) existing items from database")
            
        } catch {
            print("Error clearing database: \(error)")
            throw error
        }
    }
    
    func updateDataInDatabase(modelContext: ModelContext) async -> Bool {
        do {
                // First, delete all existing data
            try await clearAllData(modelContext: modelContext)
            
                // Fetch the wrapped response
            let routineResponse: RoutineDTOResponse = try await fetchSingleData(fromUrl: "https://diu.zahidp.xyz/api/routines")
            
                // Extract the data array from the response
            let itemData = routineResponse.data
            
                // ✅ Check if data is empty
            guard !itemData.isEmpty else {
                print("No data found in the response")
                return false
            }
            
            for eachItem in itemData {
                let itemToStore = RoutineDO(dto: eachItem)
                modelContext.insert(itemToStore)
            }
            
            try modelContext.save()
            print("Database updated successfully with \(itemData.count) items")
            return true
            
        } catch {
            print("Error updating database")
            print(error.localizedDescription)
            return false
        }
    }
    
    private func fetchArrayData<T: Decodable>(fromUrl: String) async throws -> [T] {
        guard let downloadedData: [T] = await downloadData(fromURL: fromUrl) else {
            throw NetworkError.failedToDecodeResponse
        }
        return downloadedData
    }
    
    private func fetchSingleData<T: Decodable>(fromUrl: String) async throws -> T {
        guard let downloadedData: T = await downloadData(fromURL: fromUrl) else {
            throw NetworkError.failedToDecodeResponse
        }
        return downloadedData
    }
    
    private func downloadData<T: Decodable>(fromURL: String) async -> T? {
        do {
            guard let url = URL(string: fromURL) else { throw NetworkError.badUrl }
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse else { throw NetworkError.badResponse }
            guard response.statusCode >= 200 && response.statusCode < 300 else { throw NetworkError.badStatus }
            guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else { throw NetworkError.failedToDecodeResponse }
            
            return decodedResponse
        } catch NetworkError.badUrl {
            print("There was an error creating the URL")
        } catch NetworkError.badResponse {
            print("Did not get a valid response")
        } catch NetworkError.badStatus {
            print("Did not get a 2xx status code from the response")
        } catch NetworkError.failedToDecodeResponse {
            print("Failed to decode response into the given type")
        } catch {
            print("An error occured downloading the data")
        }
        return nil
    }
}
