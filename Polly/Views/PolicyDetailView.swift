//
//  PolicyDetailView.swift
//  Polly
//

import SwiftUI
import SwiftData
import PhotosUI
import QuickLook
import UniformTypeIdentifiers

struct PolicyDetailView: View {
    let policy: Policy

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var entitlements: EntitlementManager
    @EnvironmentObject private var notificationManager: NotificationManager

    @State private var showingEditSheet = false
    @State private var showingRenewalSheet = false

    // MARK: - Archive
    @State private var showingArchiveConfirmation = false

    // MARK: - Document Pickers
    @State private var showingFilePicker = false
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    // MARK: - Pending document (between picker and label alert)
    @State private var pendingData: Data?
    @State private var pendingLabel: String = ""
    @State private var pendingFileType: FileType = .pdf

    // MARK: - Label Alert
    @State private var showingLabelAlert = false

    // MARK: - Viewer
    @State private var previewURL: URL?

    // MARK: - Delete Confirmation
    @State private var documentToDelete: PolicyDocument?

    // MARK: - Body

    // MARK: - Archive
    @State private var showingArchiveConfirmation = false

    // MARK: - Document Pickers
    @State private var showingFilePicker = false
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    // MARK: - Pending document (between picker and label alert)
    @State private var pendingData: Data?
    @State private var pendingLabel: String = ""
    @State private var pendingFileType: FileType = .pdf

    // MARK: - Label Alert
    @State private var showingLabelAlert = false

    // MARK: - Viewer
    @State private var previewURL: URL?

    // MARK: - Delete Confirmation
    @State private var documentToDelete: PolicyDocument?

    // MARK: - Body

    var body: some View {
        policyList
            .navigationTitle(policy.displayName)
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if policy.renewalDate != nil {
                        Menu {
                            Button {
                                showingRenewalSheet = true
                            } label: {
                                Label("Renew Policy", systemImage: "arrow.clockwise")
                            }
                            Button {
                                showingEditSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    } else {
                        Button("Edit") { showingEditSheet = true }
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                PolicyFormView(mode: .edit(policy))
            }
            .sheet(isPresented: $showingRenewalSheet) {
                PolicyRenewalView(policy: policy)
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.pdf, .image],
                allowsMultipleSelection: false,
                onCompletion: handleFileImport
            )
            .photosPicker(
                isPresented: $showingPhotoPicker,
                selection: $selectedPhotoItem,
                matching: .images
            )
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task { await handlePhotoPick(newItem) }
            }
            .alert("Name this document", isPresented: $showingLabelAlert) {
                TextField("Label", text: $pendingLabel)
                Button("Save") { saveDocument() }
                Button("Cancel", role: .cancel) { clearPending() }
            } message: {
                Text("Give this document a short name.")
            }
            .alert(
                "Delete \"\(documentToDelete?.label ?? "Document")\"?",
                isPresented: Binding(
                    get: { documentToDelete != nil },
                    set: { if !$0 { documentToDelete = nil } }
                )
            ) {
                Button("Delete", role: .destructive) {
                    if let doc = documentToDelete { deleteDocument(doc) }
                }
                Button("Cancel", role: .cancel) { documentToDelete = nil }
            } message: {
                Text("This cannot be undone.")
            }
            .quickLookPreview($previewURL)
            .confirmationDialog(
                "Archive \(policy.displayName)?",
                isPresented: $showingArchiveConfirmation,
                titleVisibility: .visible
            ) {
                Button("Archive Policy", role: .destructive) { archivePolicy() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This policy will be moved to your archive. You can restore it from the Policies tab.")
            }
    }

    // MARK: - List

    private var policyList: some View {
        List {
            headerSection
            costSection
            costHistorySection
            detailsSection
            remindersSection
            notesSection
            documentsSection
            archiveSection
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        Section {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(policy.category.color.gradient)
                        .frame(width: 60, height: 60)
                    Image(systemName: policy.category.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(policy.displayName)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(policy.provider)
                        .foregroundStyle(.secondary)
                    if let energyType = policy.energyType {
                        Text(energyType.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Cost Section

    @ViewBuilder
    private var costSection: some View {
        if let costRecord = policy.currentCostRecord {
            Section("Current Cost") {
                LabeledContent("Amount") {
                    Text(costRecord.cost, format: .currency(code: "GBP"))
                        .fontWeight(.semibold)
                }
                LabeledContent("Frequency") {
                    Text(costRecord.frequency.rawValue)
                }
                if let payments = costRecord.paymentsPerYear {
                    LabeledContent("Payments per year") {
                        Text("\(payments)")
                    }
                }
                LabeledContent("Annual equivalent") {
                    Text(costRecord.calculatedAnnualCost, format: .currency(code: "GBP"))
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Monthly equivalent") {
                    Text(costRecord.monthlyEquivalent, format: .currency(code: "GBP"))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Policy Details Section

    private var detailsSection: some View {
        Section("Policy Details") {
            if let accountNumber = policy.accountNumber {
                LabeledContent("Account Number", value: accountNumber)
            }
            if let startDate = policy.startDate {
                LabeledContent("Start Date") {
                    Text(startDate, format: .dateTime.day().month().year())
                }
            }
            if let renewalDate = policy.renewalDate {
                LabeledContent("Renewal Date") {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(renewalDate, format: .dateTime.day().month().year())
                        if let days = policy.daysUntilRenewal {
                            renewalLabel(days: days)
                        }
                    }
                }
            }
            LabeledContent("Auto Renews") {
                Text(policy.autoRenews ? "Yes" : "No")
            }
        }
    }

    // MARK: - Reminders Section

    private var remindersSection: some View {
        Section("Reminders") {
            LabeledContent("Reminder") {
                Text(policy.reminderEnabled ? "Enabled" : "Disabled")
            }
            if policy.reminderEnabled {
                LabeledContent("Notify before renewal") {
                    Text("\(policy.reminderDaysBefore) days")
                }
            }
        }
    }

    // MARK: - Notes Section

    @ViewBuilder
    private var notesSection: some View {
        if let notes = policy.notes, !notes.isEmpty {
            Section("Notes") {
                Text(notes)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Cost History Section

    @ViewBuilder
    private var costHistorySection: some View {
        if policy.costRecords.count > 1 || entitlements.isPremium {
            Section("Cost History") {
                if !entitlements.isPremium {
                    Label("Unlock premium to view full cost history", systemImage: "lock.fill")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    let history = sortedCostHistory
                    ForEach(Array(history.enumerated()), id: \.element.id) { index, record in
                        costHistoryRow(record, isCurrent: index == 0, previous: index + 1 < history.count ? history[index + 1] : nil)
                    }
                }
            }
        }
    }

    private var sortedCostHistory: [PolicyCostRecord] {
        policy.costRecords.sorted { $0.effectiveFrom > $1.effectiveFrom }
    }

    private func costHistoryRow(_ record: PolicyCostRecord, isCurrent: Bool, previous: PolicyCostRecord?) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(record.effectiveFrom.formatted(.dateTime.month(.abbreviated).year()))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    if isCurrent {
                        Text("Current")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(policy.category.color)
                            .clipShape(Capsule())
                    }
                }
                Text(record.frequency.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let note = record.note, !note.isEmpty {
                    Text(note)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(record.cost, format: .currency(code: "GBP"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(record.calculatedAnnualCost, format: .currency(code: "GBP"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let previous {
                    changeBadge(from: previous.calculatedAnnualCost, to: record.calculatedAnnualCost)
                }
            }
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private func changeBadge(from old: Decimal, to new: Decimal) -> some View {
        if old != 0 {
            let pct = ((new - old) / old * 100)
            let increased = new > old
            let formatted = abs(pct).formatted(.number.precision(.fractionLength(1)))
            Text("\(increased ? "▲" : "▼") \(formatted)%")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(increased ? .red : .green)
        }
    }

    // MARK: - Archive Section

    private var archiveSection: some View {
        Section {
            Button(role: .destructive) {
                showingArchiveConfirmation = true
            } label: {
                Text("Archive Policy")
                    .frame(maxWidth: .infinity)
            }
        } footer: {
            Text("Moves this policy to your archive. You can restore it at any time from the Policies tab.")
        }
    }

    // MARK: - Archive Action

    private func archivePolicy() {
        policy.isActive = false
        policy.endedAt = Date()
        notificationManager.cancelReminder(for: policy)
        dismiss()
    }

    // MARK: - Documents Section

    private var documentsSection: some View {
        Section {
            if policy.documents.isEmpty {
                Text("No documents attached")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(policy.documents.sorted(by: { $0.addedAt > $1.addedAt })) { document in
                    documentRow(document)
                }
            }
        } header: {
            HStack {
                Text("Documents")
                Spacer()
                if entitlements.isPremium {
                    addDocumentMenu
                }
            }
        }
    }

    // MARK: - Document Row

    private func documentRow(_ document: PolicyDocument) -> some View {
        Button {
            if DocumentManager.shared.exists(filename: document.filename) {
                previewURL = DocumentManager.shared.url(for: document.filename)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: document.fileType == .pdf ? "doc.fill" : "photo.fill")
                    .font(.title3)
                    .foregroundStyle(document.fileType == .pdf ? Color.red : Color.blue)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(document.label)
                        .foregroundStyle(.primary)
                        .font(.subheadline)
                    Text("\(formattedSize(document.fileSize)) · \(document.addedAt.formatted(.dateTime.day().month().year()))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                documentToDelete = document
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                documentToDelete = document
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Add Document Menu

    private var addDocumentMenu: some View {
        Menu {
            Button {
                showingFilePicker = true
            } label: {
                Label("PDF or File", systemImage: "doc.fill")
            }
            Button {
                showingPhotoPicker = true
            } label: {
                Label("Photo", systemImage: "photo.fill")
            }
        } label: {
            Image(systemName: "plus")
                .fontWeight(.semibold)
        }
    }

    // MARK: - File Import Handler

    private func handleFileImport(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result, let url = urls.first else { return }
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        guard let data = try? Data(contentsOf: url) else { return }
        let ext = url.pathExtension.lowercased()
        let isImage = ["jpg", "jpeg", "png", "heic", "heif", "gif", "webp"].contains(ext)
        pendingData = data
        pendingLabel = url.deletingPathExtension().lastPathComponent
        pendingFileType = isImage ? .image : .pdf
        showingLabelAlert = true
    }

    // MARK: - Photo Pick Handler

    private func handlePhotoPick(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        await MainActor.run {
            pendingData = data
            pendingLabel = "Photo"
            pendingFileType = .image
            selectedPhotoItem = nil
            showingLabelAlert = true
        }
    }

    // MARK: - Save Document

    private func saveDocument() {
        guard let data = pendingData else { clearPending(); return }
        let ext = pendingFileType == .pdf ? "pdf" : "jpg"
        let filename = "\(UUID().uuidString).\(ext)"
        let label = pendingLabel.trimmingCharacters(in: .whitespaces).isEmpty
            ? (pendingFileType == .pdf ? "Document" : "Photo")
            : pendingLabel
        do {
            try DocumentManager.shared.save(data: data, filename: filename)
            let doc = PolicyDocument(
                label: label,
                filename: filename,
                fileType: pendingFileType,
                fileSize: data.count
            )
            policy.documents.append(doc)
        } catch {
            print("Polly: failed to save document: \(error)")
        }
        clearPending()
    }

    // MARK: - Delete Document

    private func deleteDocument(_ doc: PolicyDocument) {
        DocumentManager.shared.delete(filename: doc.filename)
        policy.documents.removeAll { $0.id == doc.id }
        modelContext.delete(doc)
        documentToDelete = nil
    }

    // MARK: - Helpers

    private func clearPending() {
        pendingData = nil
        pendingLabel = ""
        pendingFileType = .pdf
        selectedPhotoItem = nil
    }

    private func formattedSize(_ bytes: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }

    // MARK: - Renewal Label

    @ViewBuilder
    private func renewalLabel(days: Int) -> some View {
        if days < 0 {
            Text("Overdue by \(abs(days)) days")
                .font(.caption)
                .foregroundStyle(.red)
        } else if days == 0 {
            Text("Due today")
                .font(.caption)
                .foregroundStyle(.orange)
        } else if days <= 30 {
            Text("In \(days) days")
                .font(.caption)
                .foregroundStyle(.orange)
        } else {
            Text("In \(days) days")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
