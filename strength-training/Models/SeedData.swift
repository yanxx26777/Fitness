//
//  SeedData.swift
//  strength-training
//
//  Created by Daniel Kuhlwein on 2026-02-21.
//

import Foundation
import SwiftData

struct SeedData {
    /// One-time, idempotent display-name corrections for seeded exercises.
    /// Runs on every launch and after every backup restore — existing records
    /// keep their relationships (rename only), and restoring an old backup
    /// re-applies the fix on the spot.
    static func migrateExerciseNames(context: ModelContext) {
        let renames = ["Hip Abduction (Inner)": "Hip Adduction (Inner)"]
        let descriptor = FetchDescriptor<Exercise>()
        guard let all = try? context.fetch(descriptor) else { return }
        var changed = false
        for exercise in all {
            if let newName = renames[exercise.name] {
                exercise.name = newName
                changed = true
            }
        }
        if changed { try? context.save() }
    }

    /// Removes duplicate exercises (same name + dayType), keeping the one with the most history.
    /// Records from duplicates are reassigned to the kept exercise before deletion.
    static func deduplicateExercises(context: ModelContext) {
        let exercises = (try? context.fetch(FetchDescriptor<Exercise>())) ?? []
        var grouped: [String: [Exercise]] = [:]
        for exercise in exercises {
            let key = "\(exercise.name)|\(exercise.dayType.rawValue)"
            grouped[key, default: []].append(exercise)
        }
        for (_, group) in grouped where group.count > 1 {
            // Keep the exercise with the most records
            let sorted = group.sorted { $0.recordsArray.count > $1.recordsArray.count }
            let keeper = sorted[0]
            for duplicate in sorted.dropFirst() {
                // Reassign any records from the duplicate to the keeper
                for record in duplicate.recordsArray {
                    record.exercise = keeper
                }
                context.delete(duplicate)
            }
        }
        try? context.save()
    }

    static func migrateCatalogIDs(context: ModelContext) {
        guard let exercises = try? context.fetch(FetchDescriptor<Exercise>()) else { return }
        for exercise in exercises where !exercise.isCustom && exercise.stableCatalogID == nil {
            if let entry = ExerciseCatalogEntry.all.first(where: {
                $0.fallbackName == exercise.name && $0.dayType == exercise.dayType
            }) {
                exercise.stableCatalogID = entry.stableID
            }
        }
        try? context.save()
    }

    static func seedIfNeeded(context: ModelContext) {
        guard let existing = try? context.fetch(FetchDescriptor<Exercise>()) else { return }
        for entry in ExerciseCatalogEntry.all {
            if let exercise = existing.first(where: {
                $0.stableCatalogID == entry.stableID ||
                (!$0.isCustom && $0.name == entry.fallbackName && $0.dayType == entry.dayType)
            }) {
                exercise.stableCatalogID = entry.stableID
            } else {
                let exercise = Exercise(name: entry.fallbackName, dayType: entry.dayType,
                                        muscleGroup: entry.muscleGroupKey, sortOrder: entry.sortOrder)
                exercise.stableCatalogID = entry.stableID
                context.insert(exercise)
            }
        }
        try? context.save()
    }
}
