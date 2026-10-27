import Foundation

struct ExerciseCatalogEntry {
    let stableID: String
    let fallbackName: String
    let localizedNameKey: String
    let muscleGroupKey: String
    let dayType: DayType
    let sortOrder: Int

    static let all: [Self] = [
        .init(stableID: "shoulder-press", fallbackName: "Shoulder Press", localizedNameKey: "exercise.shoulder-press", muscleGroupKey: "Shoulders", dayType: .arms, sortOrder: 0),
        .init(stableID: "rear-deltoid", fallbackName: "Rear Deltoid", localizedNameKey: "exercise.rear-deltoid", muscleGroupKey: "Shoulders", dayType: .arms, sortOrder: 1),
        .init(stableID: "pectoral-fly", fallbackName: "Pectoral Fly", localizedNameKey: "exercise.pectoral-fly", muscleGroupKey: "Chest", dayType: .arms, sortOrder: 2),
        .init(stableID: "row", fallbackName: "Row", localizedNameKey: "exercise.row", muscleGroupKey: "Back", dayType: .arms, sortOrder: 3),
        .init(stableID: "pulldown", fallbackName: "Pulldown", localizedNameKey: "exercise.pulldown", muscleGroupKey: "Back", dayType: .arms, sortOrder: 4),
        .init(stableID: "torso-rotation", fallbackName: "Torso Rotation", localizedNameKey: "exercise.torso-rotation", muscleGroupKey: "Core", dayType: .arms, sortOrder: 5),
        .init(stableID: "chest-press", fallbackName: "Chest Press", localizedNameKey: "exercise.chest-press", muscleGroupKey: "Chest", dayType: .arms, sortOrder: 6),
        .init(stableID: "biceps-curl", fallbackName: "Biceps Curl", localizedNameKey: "exercise.biceps-curl", muscleGroupKey: "Biceps", dayType: .arms, sortOrder: 7),
        .init(stableID: "triceps-press", fallbackName: "Triceps Press", localizedNameKey: "exercise.triceps-press", muscleGroupKey: "Triceps", dayType: .arms, sortOrder: 8),
        .init(stableID: "leg-curl", fallbackName: "Leg Curl", localizedNameKey: "exercise.leg-curl", muscleGroupKey: "Hamstrings", dayType: .legs, sortOrder: 0),
        .init(stableID: "calf-extension", fallbackName: "Calf Extension", localizedNameKey: "exercise.calf-extension", muscleGroupKey: "Calves", dayType: .legs, sortOrder: 1),
        .init(stableID: "leg-extension", fallbackName: "Leg Extension", localizedNameKey: "exercise.leg-extension", muscleGroupKey: "Quads", dayType: .legs, sortOrder: 2),
        .init(stableID: "glute", fallbackName: "Glute", localizedNameKey: "exercise.glute", muscleGroupKey: "Glutes", dayType: .legs, sortOrder: 3),
        .init(stableID: "back-extension", fallbackName: "Back Extension", localizedNameKey: "exercise.back-extension", muscleGroupKey: "Lower Back", dayType: .legs, sortOrder: 4),
        .init(stableID: "hip-abduction-glute", fallbackName: "Hip Abduction (Glute)", localizedNameKey: "exercise.hip-abduction-glute", muscleGroupKey: "Glutes", dayType: .legs, sortOrder: 5),
        .init(stableID: "hip-adduction-inner", fallbackName: "Hip Adduction (Inner)", localizedNameKey: "exercise.hip-adduction-inner", muscleGroupKey: "Adductors", dayType: .legs, sortOrder: 6),
        .init(stableID: "seated-leg-press", fallbackName: "Seated Leg Press", localizedNameKey: "exercise.seated-leg-press", muscleGroupKey: "Quads", dayType: .legs, sortOrder: 7),
        .init(stableID: "seated-leg-curl", fallbackName: "Seated Leg Curl", localizedNameKey: "exercise.seated-leg-curl", muscleGroupKey: "Hamstrings", dayType: .legs, sortOrder: 8),
        .init(stableID: "abdominal", fallbackName: "Abdominal", localizedNameKey: "exercise.abdominal", muscleGroupKey: "Core", dayType: .legs, sortOrder: 9),
    ]
}
