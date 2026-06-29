//
//  EventsView.swift
//  NeighborHub
//
//  Created by Haseeb Farooq on 24/06/2026.
//


import SwiftUI

struct EventsView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var eventViewModel = EventViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Header
                    headerView
                    
                    // MARK: - Content
                    if eventViewModel.isLoading && eventViewModel.events.isEmpty {
                        loadingView
                    } else if eventViewModel.events.isEmpty {
                        emptyView
                    } else {
                        eventsList
                    }
                }
                
                // MARK: - FAB
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        createButton
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $eventViewModel.showCreateEvent) {
                CreateEventView(eventViewModel: eventViewModel)
            }
            .alert("Error", isPresented: $eventViewModel.showError) {
                Button("OK") { eventViewModel.showError = false }
            } message: {
                Text(eventViewModel.errorMessage)
            }
            .onAppear {
                eventViewModel.fetchEvents()
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Community Events")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("\(eventViewModel.events.count) upcoming events")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    // MARK: - Events List
    private var eventsList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(eventViewModel.events) { event in
                    EventCardView(
                        event: event,
                        currentUserId: authViewModel.currentUser?.id ?? ""
                    ) { isJoining in
                        guard let userId = authViewModel.currentUser?.id,
                              let eventId = event.id else { return }
                        if isJoining {
                            eventViewModel.joinEvent(
                                eventId: eventId,
                                userId: userId
                            )
                        } else {
                            eventViewModel.leaveEvent(
                                eventId: eventId,
                                userId: userId
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Create Button (FAB)
    private var createButton: some View {
        Button {
            eventViewModel.showCreateEvent = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                Text("Create Event")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(hex: "E94560"))
            .cornerRadius(30)
            .shadow(
                color: Color(hex: "E94560").opacity(0.4),
                radius: 10
            )
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView().tint(Color(hex: "E94560"))
            Spacer()
        }
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(hex: "E94560").opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "E94560").opacity(0.6))
            }
            VStack(spacing: 8) {
                Text("No Events Yet")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("Be the first to organize\na community event!")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
    }
}

// MARK: - Event Card View
struct EventCardView: View {
    var event: EventModel
    var currentUserId: String
    var onJoinLeave: (Bool) -> Void
    
    var isAttending: Bool {
        event.attendees.contains(currentUserId)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Top Row
            HStack {
                // Date Badge
                VStack(spacing: 2) {
                    Text(event.date.formatted(.dateTime.month(.abbreviated)))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "E94560"))
                    Text(event.date.formatted(.dateTime.day()))
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.white)
                }
                .frame(width: 50, height: 56)
                .background(Color(hex: "E94560").opacity(0.1))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(event.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 11))
                        Text(event.organizerName)
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.white.opacity(0.4))
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11))
                        Text(event.date.formatted(.dateTime.hour().minute()))
                            .font(.system(size: 12))
                        Text("•")
                            .foregroundColor(.white.opacity(0.2))
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                        Text(event.area)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
            }
            
            // Description
            if !event.description.isEmpty {
                Text(event.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
                    .lineSpacing(3)
            }
            
            // Bottom Row
            HStack {
                // Attendees
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.4))
                    Text("\(event.attendeeCount) attending")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                // Join/Leave Button
                Button {
                    onJoinLeave(!isAttending)
                } label: {
                    Text(isAttending ? "Leave" : "Join Event")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isAttending ? .white.opacity(0.6) : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            isAttending
                            ? Color.white.opacity(0.08)
                            : Color(hex: "E94560")
                        )
                        .cornerRadius(20)
                }
            }
        }
        .padding(16)
        .background(Color(hex: "16213E"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }
}

// MARK: - Create Event View
struct CreateEventView: View {
    
    @ObservedObject var eventViewModel: EventViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showAreaPicker: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Event Title")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                            CustomTextField(
                                icon: "calendar",
                                placeholder: "e.g. Community Cleanup Drive",
                                text: $eventViewModel.eventTitle
                            )
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                            ZStack(alignment: .topLeading) {
                                if eventViewModel.eventDescription.isEmpty {
                                    Text("Tell people what this event is about...")
                                        .foregroundColor(.white.opacity(0.3))
                                        .font(.system(size: 15))
                                        .padding(16)
                                }
                                TextEditor(text: $eventViewModel.eventDescription)
                                    .foregroundColor(.white)
                                    .tint(Color(hex: "E94560"))
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 100)
                                    .padding(12)
                            }
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        
                        // Date Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Event Date & Time")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                            DatePicker(
                                "",
                                selection: $eventViewModel.eventDate,
                                in: Date()...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.graphical)
                            .tint(Color(hex: "E94560"))
                            .colorScheme(.dark)
                            .padding(12)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(14)
                        }
                        
                        // Area
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                            Button {
                                showAreaPicker = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(Color(hex: "E94560"))
                                    Text(eventViewModel.eventArea)
                                        .foregroundColor(.white)
                                        .font(.system(size: 16))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .padding(16)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Create Button
                        Button {
                            if let user = authViewModel.currentUser {
                                eventViewModel.createEvent(currentUser: user)
                            }
                        } label: {
                            ZStack {
                                if eventViewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Create Event")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(hex: "E94560"))
                            .cornerRadius(14)
                        }
                        .disabled(eventViewModel.isLoading)
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .toolbarBackground(Color(hex: "16213E"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showAreaPicker) {
                AreaPickerView(selectedArea: $eventViewModel.eventArea)
            }
        }
    }
}

#Preview {
    EventsView()
        .environmentObject(AuthViewModel())
}