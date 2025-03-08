//
//  enums.swift
//  HR Notes
//
//  Created by Theo Koester on 9/16/24.
//

import Foundation
import SwiftUI

enum Constants {
    static let updateInterval = 0.05
    static let barAmount = 6 // Adjust according to your requirement (number of bars)
    static let magnitudeLimit: Float = 32.0
}

enum BusinessCategory: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case boardMeeting = "Board Meeting"
    case brainstormingSession = "Brainstorming Session"
    case clientMeetings = "Client Meetings"
    case financialPlanning = "Financial Planning"
    case investigations = "Investigations"
    case interviews = "Interviews"
    case legalConsultation = "Legal Consultation"
    case performanceReviews = "Performance Reviews"
    case projectPlanning = "Project Planning"
    case salesCalls = "Sales Calls"
    case staffMeetings = "Staff Meetings"
    case trainingOnboarding = "Training & Onboarding"
    
    // Default note types for each business call type
    var defaultNoteTypes: [NoteType] {
        switch self {
        case .staffMeetings, .clientMeetings, .salesCalls, .projectPlanning:
            return [.executiveSummary, .actionItems, .meetingMinutes]
        case .brainstormingSession:
            return [.brainstormingIdeas, .keyPoints, .nextSteps]
        case .performanceReviews:
            return [.performanceReviewNotes, .feedbackSummary, .actionPlanForImprovement]
        case .interviews:
            return [.decisionSummary, .qaHighlights, .feedbackSummary]
        case .trainingOnboarding:
            return [.keyPoints, .studyGuide, .followUpTasks]
        case .boardMeeting, .financialPlanning, .legalConsultation:
            return [.detailedAnalysis, .decisionSummary, .financialOverview]
        case .investigations:
            return [.detailedAnalysis, .riskAssessment, .actionItems]
        }
    }
    
    // Icon for each business call type
    var icon: Image {
        switch self {
        case .boardMeeting, .staffMeetings:
            return Image(systemName: "person.2.circle")
        case .brainstormingSession:
            return Image(systemName: "lightbulb")
        case .clientMeetings, .salesCalls:
            return Image(systemName: "person.crop.circle.badge.checkmark")
        case .financialPlanning:
            return Image(systemName: "chart.bar.xaxis")
        case .investigations:
            return Image(systemName: "magnifyingglass.circle")
        case .interviews:
            return Image(systemName: "person.crop.circle.badge.questionmark")
        case .legalConsultation:
            return Image(systemName: "gavel")
        case .performanceReviews:
            return Image(systemName: "chart.line.uptrend.xyaxis")
        case .projectPlanning:
            return Image(systemName: "calendar.badge.clock")
        case .trainingOnboarding:
            return Image(systemName: "graduationcap")
        }
    }
}

enum EducationCategory: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case debates = "Debates"
    case examReview = "Exam Review/Study Guides"
    case groupProject = "Group Project"
    case labSessions = "Lab Sessions"
    case learningNewLanguage = "Learning a New Language"
    case lecturesAndClasses = "Lectures and Classes"
    case parentTeacherConference = "Parent Teacher Conference"
    case tutoringSession = "Tutoring Session"
    case educationalVideo = "Educational Video"
    
    // Default note types for each education call type
    var defaultNoteTypes: [NoteType] {
        switch self {
        case .lecturesAndClasses, .groupProject, .examReview, .debates:
            return [.keyPoints, .importantDatesAndDeadlines, .summaryForDifferentAudiences]
        case .tutoringSession:
            return [.problemSolvingSteps, .keyTermsAndDefinitions, .nextSteps]
        case .labSessions:
            return [.labResultsSummary, .keyPoints, .actionPlanForImprovement]
        case .parentTeacherConference:
            return [.parentTeacherConferenceSummary, .feedbackSummary, .actionPlanForImprovement]
        case .learningNewLanguage:
            return [.keyTermsAndDefinitions, .studyGuide, .flashcards]
        case .educationalVideo:
            return [.abstractSummary, .keyPoints, .conceptMaps]
        }
    }
    
    // Icon for each education call type
    var icon: Image {
        switch self {
        case .debates:
            return Image(systemName: "mic.circle")
        case .examReview, .educationalVideo:
            return Image(systemName: "book.circle")
        case .groupProject, .labSessions:
            return Image(systemName: "person.3.sequence.fill")
        case .lecturesAndClasses, .tutoringSession:
            return Image(systemName: "book")
        case .parentTeacherConference:
            return Image(systemName: "person.2.fill")
        case .learningNewLanguage:
            return Image(systemName: "textformat.abc")
        }
    }
}

enum PersonalCategory: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case budgeting = "Budgeting"
    case counselingTherapy = "Counseling/Therapy"
    case familyMeetings = "Family Meetings"
    case gameNights = "Game Nights"
    case goalSetting = "Goal Setting"
    case mindMapping = "Mind Mapping"
    case personalJournaling = "Personal Journaling"
    case storyTelling = "Story Telling"
    case vacationPlanning = "Vacation Planning"
    
    // Default note types for each personal call type
    var defaultNoteTypes: [NoteType] {
        switch self {
        case .personalJournaling:
            return [.personalReflections, .gratitudeList, .dailyPlanner]
        case .goalSetting:
            return [.goalTracker, .actionPlanForImprovement, .prioritiesList]
        case .vacationPlanning:
            return [.vacationItinerary, .budgetAndFinancialNotes, .nextSteps]
        case .budgeting:
            return [.budgetAndFinancialNotes, .actionItems, .detailedAnalysis]
        case .familyMeetings:
            return [.familyMeetingNotes, .agendaOutline, .followUpTasks]
        case .storyTelling:
            return [.storyOutline, .creativeIdeasList, .keyPoints]
        case .counselingTherapy:
            return [.counselingInsights, .actionPlanForImprovement, .personalReflections]
        case .gameNights:
            return [.scoreTracking, .keyPoints, .agendaOutline]
        case .mindMapping:
            return [.mindMapping, .creativeIdeasList, .nextSteps]
        }
    }
    
    // Icon for each personal call type
    var icon: Image {
        switch self {
        case .budgeting:
            return Image(systemName: "dollarsign.circle")
        case .counselingTherapy:
            return Image(systemName: "heart.text.square")
        case .familyMeetings:
            return Image(systemName: "house.circle")
        case .gameNights:
            return Image(systemName: "gamecontroller")
        case .goalSetting:
            return Image(systemName: "target")
        case .mindMapping:
            return Image(systemName: "network")
        case .personalJournaling:
            return Image(systemName: "pencil.circle")
        case .storyTelling:
            return Image(systemName: "text.book.closed")
        case .vacationPlanning:
            return Image(systemName: "airplane.circle")
        }
    }
}

enum GeneralCategory: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case any = "Any"
    case brainstorming = "Brainstorming"
    case catchUp = "Catch-Up"
    case chat = "Chat"
    case checkIn = "Check-In"
    case discussion = "Discussion"
    case openForum = "Open Forum"
    case planningSession = "Planning Session"
    
    var defaultNoteTypes: [NoteType] {
        switch self {
        case .any:
            return [.keyPoints, .nextSteps, .summaryForDifferentAudiences]
        case .brainstorming:
            return [.brainstormingIdeas, .creativeIdeasList, .nextSteps]
        case .catchUp:
            return [.agendaOutline, .summaryForDifferentAudiences, .nextSteps]
        case .chat:
            return [.keyPoints, .motivationalPoints, .nextSteps]
        case .checkIn:
            return [.keyPoints, .nextSteps, .actionItems]
        case .discussion:
            return [.detailedAnalysis, .prosAndConsList, .keyPoints]
        case .openForum:
            return [.keyPoints, .resourceList, .nextSteps]
        case .planningSession:
            return [.projectPlanningNotes, .actionItems, .agendaOutline]
        }
    }
    
    // Icon for each general call type
    var icon: Image {
        switch self {
        case .any:
            return Image(systemName: "questionmark.circle")
        case .brainstorming:
            return Image(systemName: "lightbulb")
        case .catchUp:
            return Image(systemName: "message")
        case .chat:
            return Image(systemName: "text.bubble")
        case .checkIn:
            return Image(systemName: "message.badge.checkmark")
        case .discussion:
            return Image(systemName: "bubble.left.and.bubble.right")
        case .openForum:
            return Image(systemName: "dot.radiowaves.left.and.right")
        case .planningSession:
            return Image(systemName: "calendar.badge.clock")
        }
    }
}

enum CallTypeCategory: String, CaseIterable {
    case general = "General"
    case hr = "Human Resources"
    case sales = "Sales"
    case support = "Support"
    case project = "Project Management"
}

enum NoteCategory: String, CaseIterable {
    case business = "Business"
    case education = "Education"
    case personal = "Personal Development"
    case general = "General"
}

// Enum for all possible note types
enum NoteType: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    // Business
    case actionItems = "Action Items"
    case brainstormingIdeas = "Brainstorming Ideas"
    case clientMeetingRecap = "Client Meeting Recap"
    case decisionSummary = "Decision Summary"
    case executiveSummary = "Executive Summary"
    case feedbackSummary = "Feedback Summary"
    case financialOverview = "Financial Overview"
    case followUpTasks = "Follow-Up Tasks"
    case keyPoints = "Key Points"
    case meetingMinutes = "Meeting Minutes"
    case negotiationOutcomes = "Negotiation Outcomes"
    case performanceReviewNotes = "Performance Review Notes"
    case projectPlanningNotes = "Project Planning Notes"
    case riskAssessment = "Risk Assessment"
    case salesCallSummary = "Sales Call Summary"
    case strategyOutline = "Strategy Outline"
    case swotAnalysis = "SWOT Analysis"
    
    // Educational
    case abstractSummary = "Abstract Summary"
    case actionPlanForImprovement = "Action Plan for Improvement"
    case conceptMaps = "Concept Maps"
    case debateHighlights = "Debate Highlights"
    case flashcards = "Flashcards"
    case importantDatesAndDeadlines = "Important Dates and Deadlines"
    case keyTermsAndDefinitions = "Key Terms and Definitions"
    case labResultsSummary = "Lab Results Summary"
    case lectureNotes = "Lecture Notes"
    case parentTeacherConferenceSummary = "Parent-Teacher Conference Summary"
    case problemSolvingSteps = "Problem-Solving Steps"
    case qaHighlights = "Q&A Highlights"
    case studyGuide = "Study Guide"
    
    // Personal
    case budgetAndFinancialNotes = "Budget and Financial Notes"
    case counselingInsights = "Counseling Insights"
    case creativeIdeasList = "Creative Ideas List"
    case dailyPlanner = "Daily Planner"
    case familyMeetingNotes = "Family Meeting Notes"
    case goalTracker = "Goal Tracker"
    case gratitudeList = "Gratitude List"
    case healthAndWellnessLog = "Health and Wellness Log"
    case mindMapping = "Mind Mapping"
    case personalReflections = "Personal Reflections"
    case scoreTracking = "Score Tracking"
    case storyOutline = "Story Outline"
    case vacationItinerary = "Vacation Itinerary"
    
    // General
    case agendaOutline = "Agenda Outline"
    case detailedAnalysis = "Detailed Analysis"
    case faqs = "FAQs"
    case lessonsLearned = "Lessons Learned"
    case motivationalPoints = "Motivational Points"
    case nextSteps = "Next Steps"
    case prioritiesList = "Priorities List"
    case prosAndConsList = "Pros and Cons List"
    case resourceList = "Resource List"
    case summaryForDifferentAudiences = "Summary for Different Audiences"
    
    // Function to return all business-related note types
    static func businessRelated() -> [NoteType] {
        return [
            .actionItems, .brainstormingIdeas, .clientMeetingRecap, .decisionSummary, .executiveSummary,
            .feedbackSummary, .financialOverview, .followUpTasks, .keyPoints, .meetingMinutes,
            .negotiationOutcomes, .performanceReviewNotes, .projectPlanningNotes, .riskAssessment,
            .salesCallSummary, .strategyOutline, .swotAnalysis
        ]
    }
    
    // Function to return all educational-related note types
    static func educationRelated() -> [NoteType] {
        return [
            .abstractSummary, .actionPlanForImprovement, .conceptMaps, .debateHighlights, .flashcards,
            .importantDatesAndDeadlines, .keyTermsAndDefinitions, .labResultsSummary, .lectureNotes,
            .parentTeacherConferenceSummary, .problemSolvingSteps, .qaHighlights, .studyGuide
        ]
    }
    
    // Function to return all personal-related note types
    static func personalRelated() -> [NoteType] {
        return [
            .budgetAndFinancialNotes, .counselingInsights, .creativeIdeasList, .dailyPlanner,
            .familyMeetingNotes, .goalTracker, .gratitudeList, .healthAndWellnessLog, .mindMapping,
            .personalReflections, .scoreTracking, .storyOutline, .vacationItinerary
        ]
    }
    
    // Function to return all general-related note types
    static func generalRelated() -> [NoteType] {
        return [
            .agendaOutline, .detailedAnalysis, .faqs, .lessonsLearned, .motivationalPoints,
            .nextSteps, .prioritiesList, .prosAndConsList, .resourceList, .summaryForDifferentAudiences
        ]
    }
}

