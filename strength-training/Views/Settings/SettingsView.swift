//
//  SettingsView.swift
//  strength-training
//
//  Created by Daniel Kuhlwein on 2026-02-21.
//

import SwiftUI
import SwiftData
import UIKit
internal import UniformTypeIdentifiers
import CloudKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    var healthKitService: HealthKitWorkoutService
    var cloudKitSyncService: CloudKitSyncService

    @State private var exportFile: BackupExportFile?
    @State private var fileToClean: BackupExportFile?
    @State private var isImporting = false
    @State private var pendingRestoreData: Data?
    @State private var showRestoreConfirmation = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var successMessage = ""

    @AppStorage("progressionAggressiveness")
    private var aggressiveness: String = ProgressionAggressiveness.moderate.rawValue

    @AppStorage("weightUnitSystem") private var weightUnitSystem = "metric"

    var body: some View {
        NavigationStack {
            List {
                Section("Weight Unit") {
                    Picker("Weight Unit", selection: $weightUnitSystem) {
                        Text("Kilograms").tag("metric")
                        Text("Pounds").tag("imperial")
                    }
                }

                Section {
                    if healthKitService.isAvailable {
                        switch healthKitService.authorizationStatus {
                        case .none:
                            Button {
                                Task {
                                    await healthKitService.requestAuthorization()
                                }
                            } label: {
                                Label("Connect Apple Health", systemImage: "heart.fill")
                            }
                        case true?:
                            Label("Apple Health Connected", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(Color.uplift.ahGreen)
                        case false?:
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Apple Health Not Authorized", systemImage: "exclamationmark.triangle")
                                    .foregroundStyle(Color.uplift.customBadge)
                                Text("Open Settings > Privacy > Health to grant access.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        Label("Apple Health Not Available", systemImage: "heart.slash")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    sectionHeader("Health")
                } footer: {
                    sectionFooter("When connected, workouts are saved to Apple Health for Activity Ring credit and fitness tracking.")
                }
                .listRowBackground(Color.uplift.surface1)

                Section {
                    UpliftSegmentedControl(
                        segments: ProgressionAggressiveness.allCases.map { mode in
                            UpliftSegment(id: mode.rawValue, label: mode.rawValue)
                        },
                        selection: $aggressiveness
                    )
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 4)
                    .listRowBackground(Color.clear)
                } header: {
                    sectionHeader("Progressive Overload")
                } footer: {
                    sectionFooter("Moderate recommends a weight increase after 2 consistent sessions. Conservative requires 3.")
                }
                .listRowBackground(Color.uplift.surface1)

                iCloudSyncSection

                Section {
                    Button(action: exportBackup) {
                        Label("Export Backup", systemImage: "square.and.arrow.up")
                            .foregroundStyle(Color.uplift.accent)
                    }

                    Button {
                        isImporting = true
                    } label: {
                        Label("Restore from Backup", systemImage: "square.and.arrow.down")
                            .foregroundStyle(Color.uplift.customBadge)
                    }
                } header: {
                    sectionHeader("Data Management")
                } footer: {
                    sectionFooter("Export a complete backup of your data as a JSON file for safekeeping or to transfer to another device. Restoring replaces all current data.")
                }
                .listRowBackground(Color.uplift.surface1)
            }
            .scrollContentBackground(.hidden)
            .background(Color.uplift.bgElev)
            .navigationTitle("Settings")
            .sheet(item: $exportFile, onDismiss: {
                fileToClean?.remove()
                fileToClean = nil
            }) { file in
                BackupShareSheet(url: file.url)
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImportResult(result)
            }
            .confirmationDialog(
                "Restore Backup?",
                isPresented: $showRestoreConfirmation,
                titleVisibility: .visible
            ) {
                Button("Replace All Data", role: .destructive) {
                    if let data = pendingRestoreData {
                        performRestore(data: data)
                    }
                }
                Button("Cancel", role: .cancel) {
                    pendingRestoreData = nil
                }
            } message: {
                Text("This will permanently replace all current workout data. This cannot be undone.")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(successMessage)
            }
        }
    }

    // MARK: - iCloud Sync Section

    @ViewBuilder
    private var iCloudSyncSection: some View {
        Section {
            Label("Stored on this device", systemImage: "iphone")
            Text("iCloud sync is not configured in this version.")
                .font(.caption)
                .foregroundStyle(.secondary)
        } header: {
            sectionHeader("iCloud Sync")
        } footer: {
            sectionFooter("Export backups regularly. Deleting the app also deletes its local data.")
        }
        .listRowBackground(Color.uplift.surface1)
    }

    // MARK: - Section text styling

    private func sectionHeader(_ text: String) -> some View {
        Text(AppLocalization.text(text))
            .textCase(.uppercase)
            .font(.uplift.text(11, weight: .bold))
            .tracking(0.6)
            .foregroundStyle(Color.uplift.fgMuted)
    }

    private func sectionFooter(_ text: String) -> some View {
        Text(AppLocalization.text(text))
            .font(.uplift.text(12, weight: .medium))
            .foregroundStyle(Color.uplift.fgDim)
    }

    // MARK: - Actions

    private func exportBackup() {
        do {
            let data = try BackupService.export(context: modelContext)
            let file = try BackupExportFile(data: data)
            fileToClean = file
            exportFile = file
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = String(localized: "Could not access the selected file.")
                showError = true
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                pendingRestoreData = try Data(contentsOf: url)
                showRestoreConfirmation = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func performRestore(data: Data) {
        do {
            try BackupService.restore(from: data, context: modelContext)
            successMessage = String(localized: "Backup restored successfully.")
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
