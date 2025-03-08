//
//  AudioUploadStatusViewModel.swift
//  NoteBot
//
//  Created by Theo Koester on 3/6/25.
//


import Foundation
import Combine

enum UploadStatus: String {
    case queued = "queued"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
}

struct QueuedUpload: Identifiable {
    let id: String // document_id from server as String
    var status: UploadStatus
    var errorMessage: String?
    var lastChecked: Date
    
    // Add any additional metadata you want to track
    let fileName: String
    let uploadDate: Date
}

@MainActor
class AudioUploadStatusViewModel: ObservableObject {
    @Published private(set) var queuedUploads: [QueuedUpload] = []
    @Published var isPolling: Bool = false
    
    private var pollingTimer: Timer?
    private let pollingInterval: TimeInterval = 60 // 60 seconds
    
    init() {
        startPollingIfNeeded()
    }
    
    func addUpload(documentId: String, fileName: String) {
        let newUpload = QueuedUpload(
            id: documentId,
            status: .queued,
            lastChecked: Date(),
            fileName: fileName,
            uploadDate: Date()
        )
        queuedUploads.append(newUpload)
        startPollingIfNeeded()
    }
    
    private func startPollingIfNeeded() {
        guard !queuedUploads.isEmpty && !isPolling else { return }
        
        isPolling = true
        pollingTimer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.checkUploadStatuses()
            }
        }
        
        // Initial check immediately
        Task {
            await checkUploadStatuses()
        }
    }
    
    private func stopPollingIfDone() {
        let hasIncompleteUploads = queuedUploads.contains { upload in
            upload.status != .completed && upload.status != .failed
        }
        
        if !hasIncompleteUploads {
            pollingTimer?.invalidate()
            pollingTimer = nil
            isPolling = false
        }
    }
    
    private func checkUploadStatuses() async {
        do {
            let statusResponses = try await NetworkManager.shared.getQueueStatus()
            
            
            for (index, upload) in queuedUploads.enumerated() {
                if let matchingStatus = statusResponses.first(where: { $0.document_id == upload.id }) {
                    var updatedUpload = upload
                    
                    // Update status based on server response
                    switch matchingStatus.status {
                    case "completed":
                        updatedUpload.status = .completed
                    case "failed":
                        updatedUpload.status = .failed
                    case "processing":
                        updatedUpload.status = .processing
                    case "pending":
                        updatedUpload.status = .queued
                    default:
                        updatedUpload.status = .queued
                    }
                    
                    updatedUpload.lastChecked = Date()
                    queuedUploads[index] = updatedUpload
                }
            }
        } catch {
            // Handle error for all uploads in queue
            for (index, upload) in queuedUploads.enumerated() {
                var updatedUpload = upload
                updatedUpload.status = .failed
                updatedUpload.errorMessage = error.localizedDescription
                updatedUpload.lastChecked = Date()
                queuedUploads[index] = updatedUpload
            }
        }
        
        // Clean up completed/failed uploads older than 24 hours
        let twentyFourHoursAgo = Date().addingTimeInterval(-86400)
        queuedUploads.removeAll { upload in
            (upload.status == .completed || upload.status == .failed) &&
            upload.lastChecked < twentyFourHoursAgo
        }
        
        stopPollingIfDone()
    }
    
    func removeUpload(id: String) {
        queuedUploads.removeAll { $0.id == id }
        stopPollingIfDone()
    }
    
    deinit {
        pollingTimer?.invalidate()
    }
}
