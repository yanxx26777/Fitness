# Fitness iOS development

Use a recent stable Xcode with Swift 6 and an installed iOS simulator runtime. The minimum application deployment target is iOS 17. Local validation used Xcode 27.1 and iOS 27.1 (iPhone Duo); deployment-target compilation checks iOS 17 API availability, but runtime checks on iOS 17 and physical devices are still required before release.

```sh
git clone https://github.com/yanxx26777/Fitness.git
cd Fitness
open strength-training.xcodeproj
```

Select the `strength-training` scheme. The display name is Fitness; the committed bundle identifier is `com.yanxx26777.fitness`. The repository contains no developer Team ID or production signing credentials.

For device signing, copy `Config/Local.xcconfig.example` to `Config/Local.xcconfig`, fill in your own Team ID and bundle identifier, and pass `-xcconfig Config/Local.xcconfig` to xcodebuild (or assign that file as a local Xcode build configuration). This ignored file is optional for simulators. Automatic signing requires your own Apple Developer account.

## Validation

```sh
xcodebuild clean build -project strength-training.xcodeproj -scheme strength-training -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
DESTINATION=$(python3 scripts/ios-destination.py)
xcodebuild test -project strength-training.xcodeproj -scheme strength-training -destination "$DESTINATION" -parallel-testing-enabled NO -resultBundlePath TestResults.xcresult CODE_SIGNING_ALLOWED=NO
xcrun xcresulttool get test-results summary --path TestResults.xcresult
```

Delete or rename an existing `TestResults.xcresult` before repeating the command. CI preserves results and checks for nonzero tests, zero failures and zero skips.

## Data and permissions

SwiftData uses a local store with CloudKit explicitly disabled. No iCloud account is needed. Export JSON backups in Profile; deleting the app deletes local data. Restoring replaces current data after confirmation. Stored weights and JSON backups retain pounds for compatibility; the UI defaults to kilograms and can switch to pounds.

Simplified Chinese and English are supported. Set the simulator language to Simplified Chinese to check Chinese screens; unsupported languages fall back to English. Exercise names are displayed through stable catalog keys; custom names are retained.

Apple Health is optional and requires a properly signed physical device. The simulator reports it unavailable. Request permission from Profile. iOS 17–25 saves workouts through HKWorkoutBuilder; iOS 26+ supports live iPhone workout sessions. Effort scores require iOS 18+. Local recording works without HealthKit authorization.

iCloud production containers, conflict handling, signing, TestFlight, authorized media, privacy/release review and App Store submission remain Phase 5 work. This repository does not inherit upstream Xcode Cloud deployment or App Store identity.
