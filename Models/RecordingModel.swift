//
//  RecordingModel.swift
//  HR Notes
//
//  Created by Theo Koester on 9/14/24.
//

import Foundation
import SwiftUI

// Define a wrapper struct to match the response structure
struct CallDetailsResponse: Codable {
    let call_details: [CallDetails]
}

// Update CallDetails to handle empty response
struct CallDetails: Codable, Identifiable {
    var id = UUID()
    var user_id: String?
    var date: Date
    var callType: String?
    var notes: String
    var participants: [Participant]
    var notetype: [String]
    var minutesElapsed: Double
    var title: String?
    var transcription: Transcription?
    var tokenUsage: TokenUsage?
    var noteTypeResponse: [String: NoteTypeResponse]?
    var _cls: String?  // Add this field to match server response
    
    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case date
        case callType = "callType"
        case notes
        case participants
        case notetype
        case minutesElapsed = "minutes_elapsed"
        case title
        case transcription
        case tokenUsage = "token_usage"
        case noteTypeResponse = "note_type_responses"
        case _cls
    }
    
    // Add custom init to handle empty response
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle _cls field
        _cls = try container.decodeIfPresent(String.self, forKey: ._cls)
        
        // If we only have _cls, initialize with default values
        if container.allKeys.count == 1 {
            id = UUID()
            user_id = nil
            date = Date()
            callType = nil
            notes = ""
            participants = []
            notetype = []
            minutesElapsed = 0
            title = nil
            transcription = nil
            tokenUsage = nil
            noteTypeResponse = nil
            return
        }
        
        // Otherwise decode all fields normally
        id = UUID()
        user_id = try container.decodeIfPresent(String.self, forKey: .user_id)
        date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        callType = try container.decodeIfPresent(String.self, forKey: .callType)
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        participants = try container.decodeIfPresent([Participant].self, forKey: .participants) ?? []
        notetype = try container.decodeIfPresent([String].self, forKey: .notetype) ?? []
        minutesElapsed = try container.decodeIfPresent(Double.self, forKey: .minutesElapsed) ?? 0
        title = try container.decodeIfPresent(String.self, forKey: .title)
        transcription = try container.decodeIfPresent(Transcription.self, forKey: .transcription)
        tokenUsage = try container.decodeIfPresent(TokenUsage.self, forKey: .tokenUsage)
        noteTypeResponse = try container.decodeIfPresent([String: NoteTypeResponse].self, forKey: .noteTypeResponse)
    }

    // Computed property to return participants ordered by hosts first
    var orderedParticipants: [Participant] {
        return participants.sorted { $0.isHost && !$1.isHost }
    }

    // Helper method to get the correct icon based on callType
    var icon: Image {
        guard let category = getCallTypeCategory() else {
            return Image(systemName: "questionmark.circle")
        }
        return category.icon
    }

    // Method to parse callType and return the corresponding category enum
    private func getCallTypeCategory() -> CallTypeIconProvider? {
        guard let callType = callType else { return nil }
        let components = callType.split(separator: "-").map { $0.trimmingCharacters(in: .whitespaces) }
        guard components.count == 2 else { return nil }
        
        let category = components[0]
        let subcategory = components[1]

        switch category.lowercased() {
        case "business":
            return BusinessCategory(rawValue: subcategory)
        case "education":
            return EducationCategory(rawValue: subcategory)
        case "personal":
            return PersonalCategory(rawValue: subcategory)
        case "general":
            return GeneralCategory(rawValue: subcategory)
        default:
            return nil
        }
    }
}

// Add Transcription struct with optional fields
struct Transcription: Codable {
    let utterances: [Utterance]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        utterances = try container.decodeIfPresent([Utterance].self, forKey: .utterances)
    }
    
    enum CodingKeys: String, CodingKey {
        case utterances
    }
}

struct Utterance: Codable, Identifiable {
    var id = UUID()
    let speaker: String
    let start: Int
    let end: Int
    let text: String
    let confidence: Double
}

// Protocol to provide an icon for each category
protocol CallTypeIconProvider {
    var icon: Image { get }
}

// Make each category conform to CallTypeIconProvider
extension BusinessCategory: CallTypeIconProvider {}
extension EducationCategory: CallTypeIconProvider {}
extension PersonalCategory: CallTypeIconProvider {}
extension GeneralCategory: CallTypeIconProvider {}

// Participant struct remains unchanged, matching the server's response
struct Participant: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var role: String
    var isHost: Bool
    var additionalNotes: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case role
        case isHost
        case additionalNotes
    }
}

// TokenUsage struct to match the token usage part of the response
struct TokenUsage: Codable {
    let transcriptionCost: Double
    let inputCost: Double
    let outputCost: Double
    let totalCost: Double

    enum CodingKeys: String, CodingKey {
        case transcriptionCost = "transcription_cost"
        case inputCost = "input_cost"
        case outputCost = "output_cost"
        case totalCost = "total_cost"
    }
}

// This new structure allows us to handle both strings and arrays in note_type_responses
enum NoteTypeResponse: Codable {
    case string(String)
    case array([String])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let arrayValue = try? container.decode([String].self) {
            self = .array(arrayValue)
        } else {
            throw DecodingError.typeMismatch(
                NoteTypeResponse.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected String or Array of Strings")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .array(let values):
            try container.encode(values)
        }
    }
}

struct Recording: Identifiable {
    let id: String
    let title: String
    let date: Date
    let duration: String
    let fileURL: URL
    
}
