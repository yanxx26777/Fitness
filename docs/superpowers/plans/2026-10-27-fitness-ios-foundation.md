# Fitness iOS Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Import UpLift into the Fitness repository and produce a Chinese-first, metric-first, locally runnable iOS foundation on which action teaching, personalized plans, guided courses, and mainland China release work can be built.

**Architecture:** Preserve UpLift's SwiftUI/MVVM/SwiftData structure and MIT history, but place launch configuration behind a local-first `ModelContainerFactory`, unit presentation behind a pure `WeightUnitSystem`, localization behind a String Catalog, and navigation behind a typed `AppTab`. Store existing weights in pounds internally during this phase to avoid a destructive SwiftData migration; convert only at input/output boundaries.

**Tech Stack:** Swift 6, SwiftUI, SwiftData, XCTest, HealthKit, GitHub Actions with a macOS/Xcode runner

**Spec:** `docs/superpowers/specs/2026-10-27-beginner-fitness-ios-design.md`

## Global Constraints

- Use `danielkuhlwein/strength-training` commit `c881a180b66924e86d1ee1270fc8f28ab6f3b5d9` as the imported base and preserve its MIT license and copyright notice.
- This is a new App; do not reuse the upstream developer Team, Bundle ID, iCloud container, push entitlement, or App Store identity.
- Target iOS 17.0 or later; APIs introduced after iOS 17 require an availability guard or an iOS 17 fallback.
- Use Simplified Chinese as the primary user-facing language and metric units as the default; retain English fallback and pounds as a user preference.
- Keep SwiftData's stored `weightLbs` values unchanged in this phase; `WeightUnitSystem` owns all conversion and formatting.
- Keep the current instance local-first. CloudKit remains disabled until the release plan supplies a user-owned container and verifies conflict handling.
- Do not add third-party dependencies in this phase.
- Do not add action videos, copied third-party branding, or production credentials in this phase.
- Run development in the existing `/workspace/Fitness` checkout; do not create a worktree unless the user explicitly requests one.

## Delivery Roadmap

This plan implements Phase 1 only. Each later phase gets its own implementation plan after the interfaces from the preceding phase exist:

1. Foundation: upstream import, local configuration, iOS 17 baseline, metric units, Chinese shell, and CI.
2. Action teaching: 30-action schema, bundled catalog, teaching UI, media manifest, player, download manager, checksums, and offline fallback.
3. Personalized plans: onboarding assessment, rule engine, three starter programs, substitutions, Today integration, and plan progress.
4. Guided courses: six starter courses, timeline player, audio cues, interruption restore, per-course download, and unified workout history.
5. Mainland release: authorized media replacement, HealthKit/iCloud production configuration, privacy surfaces, accessibility, App filing inputs, TestFlight, and App Store evidence.

## File Structure

- `strength-training/App/FitnessApp.swift`: application entry and model-container injection.
- `strength-training/App/ModelContainerFactory.swift`: local SwiftData configuration and later CloudKit seam.
- `strength-training/App/AppTab.swift`: typed five-tab identity and localized labels.
- `strength-training/App/AppShellView.swift`: root navigation shell.
- `strength-training/Services/WeightUnitSystem.swift`: pure pounds/kilograms conversion, steps, units, and formatting.
- `strength-training/Resources/Localizable.xcstrings`: English fallback and Simplified Chinese translations.
- `strength-training/Models/SeedData.swift`: stable seed identifiers and Chinese display metadata without translating persisted identity.
- `strength-training-tests/ModelContainerFactoryTests.swift`: in-memory launch and persistence configuration tests.
- `strength-training-tests/WeightUnitSystemTests.swift`: conversion, rounding, formatting, and invalid-input tests.
- `strength-training-tests/AppTabTests.swift`: shell identity and localized title tests.
- `strength-training-tests/SeedDataTests.swift`: idempotent seed and localized display tests.
- `.github/workflows/ios-ci.yml`: clean simulator build and unit tests on macOS.
- `Config/Local.xcconfig.example`: non-secret signing and identity values users must provide locally.
- `docs/development/ios-setup.md`: exact Xcode, signing, local configuration, and test commands.

## Review Focus

- Missing or malformed saved unit preference must fall back to kilograms without corrupting stored pounds; Task 3 tests `test_invalidRawValue_fallsBackToMetric`.
- Zero, negative, non-finite, and extremely large weights must format predictably and never surface `nan`/`inf`; Task 3 tests `test_displayWeight_sanitizesInvalidValues`.
- Launching without an iCloud account or entitlement must create a local store and never crash; Task 2 tests `test_makeLocalContainer_usesNoCloudKitDatabase`.
- Re-running seed logic after reinstall/restore must not duplicate exercises or sever history; Task 4 tests `test_seedIfNeeded_isIdempotent`.
- Missing Simplified Chinese catalog entries must display the English fallback rather than an empty label; Task 4 tests `test_missingChineseTranslation_fallsBackToEnglishValue`.

---

### Task 1: Import and Record the UpLift Baseline

**Files:**
- Import: upstream application, tests, project, screenshots, README, and `LICENSE`
- Create: `docs/development/upstream.md`
- Preserve: `docs/superpowers/specs/2026-10-27-beginner-fitness-ios-design.md`
- Preserve: `docs/superpowers/plans/2026-10-27-fitness-ios-foundation.md`

**Interfaces:**
- Consumes: upstream Git commit `c881a180b66924e86d1ee1270fc8f28ab6f3b5d9`.
- Produces: a single repository containing the upstream source/history plus Fitness design and plan documents; remote `origin` remains `yanxx26777/Fitness`, remote `upstream` points to `danielkuhlwein/strength-training`.

- [ ] **Step 1: Record the current Fitness commit and clean-worktree status**

Run: `git rev-parse HEAD && git status --short && git remote -v`

Expected: the design/plan commit is present, the worktree has no unrelated changes, and `origin` is the Fitness repository.

- [ ] **Step 2: Fetch the exact upstream baseline**

Run: `git remote add upstream https://github.com/danielkuhlwein/strength-training.git && git fetch upstream c881a180b66924e86d1ee1270fc8f28ab6f3b5d9`

Expected: `FETCH_HEAD` resolves to `c881a180b66924e86d1ee1270fc8f28ab6f3b5d9`.

- [ ] **Step 3: Merge the unrelated histories without changing either license or design document**

Run: `git merge --allow-unrelated-histories --no-edit c881a180b66924e86d1ee1270fc8f28ab6f3b5d9`

Expected: the merge completes; `LICENSE` contains Daniel Kuhlwein's MIT notice; both spec and plan remain present.

- [ ] **Step 4: Write `docs/development/upstream.md`**

Document the upstream URL, imported commit, MIT preservation requirement, and the rule that future upstream updates use reviewed merges rather than overwriting Fitness changes.

- [ ] **Step 5: Verify the imported source inventory**

Run: `test -f strength-training.xcodeproj/project.pbxproj && test -f strength-training/strength_trainingApp.swift && test -f LICENSE && git diff --check HEAD^ HEAD`

Expected: exit 0.

- [ ] **Step 6: Commit**

```bash
git add docs/development/upstream.md
git commit -m "docs: record UpLift upstream baseline"
```

### Task 2: Establish a Local-First Fitness App Configuration

**Files:**
- Create: `strength-training/App/FitnessApp.swift`
- Create: `strength-training/App/ModelContainerFactory.swift`
- Create: `strength-training-tests/ModelContainerFactoryTests.swift`
- Create: `Config/Local.xcconfig.example`
- Modify: `strength-training/strength_trainingApp.swift`
- Modify: `strength-training/strength-training.entitlements`
- Modify: `strength-training.xcodeproj/project.pbxproj`
- Modify: `.gitignore`

**Interfaces:**
- Consumes: existing models `Exercise`, `WorkoutSession`, `ExerciseRecord`, `SetRecord`.
- Produces: `enum ModelContainerFactory { static func make(inMemory: Bool = false, cloudSyncEnabled: Bool = false) throws -> ModelContainer }`; `struct FitnessApp: App`; a local-only default store with an explicit future CloudKit seam.

- [ ] **Step 1: Write failing `ModelContainerFactoryTests`**

Add `test_makeInMemoryContainer_insertsAndFetchesExercise`, `test_makeLocalContainer_usesNoCloudKitDatabase`, and `test_makeContainer_registersAllFourBaselineModels`. Assert an in-memory save/fetch round trip and that the default configuration is local-only.

- [ ] **Step 2: Run the focused test and confirm the factory is missing**

Run: `xcodebuild test -project strength-training.xcodeproj -scheme strength-training -destination 'platform=iOS Simulator,OS=latest,name=iPhone 16 Pro' -only-testing:strength-training-tests/ModelContainerFactoryTests CODE_SIGNING_ALLOWED=NO`

Expected: FAIL because `ModelContainerFactory` does not exist.

- [ ] **Step 3: Implement `ModelContainerFactory.make(inMemory:cloudSyncEnabled:)`**

Use the existing four-model schema. For `cloudSyncEnabled == false`, create a `ModelConfiguration` with no CloudKit database; reject `true` with a typed `ConfigurationError.cloudKitNotConfigured` until Phase 5 supplies a container.

- [ ] **Step 4: Make `FitnessApp` the `@main` entry and inject the factory result**

Retain a fatal launch error only for an unrecoverable local-store creation failure. Remove the obsolete `strength_trainingApp` app declaration after the new entry compiles.

- [ ] **Step 5: Remove upstream signing identities and remote capabilities from the development baseline**

Set product display name to `Fitness`, deployment target to `17.0`, clear committed `DEVELOPMENT_TEAM`, use placeholder Bundle ID `com.yanxx26777.fitness`, remove upstream iCloud container/push entries from the entitlements file, and keep HealthKit capability for later physical-device validation.

- [ ] **Step 6: Add local configuration documentation surface**

Create `Config/Local.xcconfig.example` with commented `DEVELOPMENT_TEAM` and `PRODUCT_BUNDLE_IDENTIFIER` examples; ignore `Config/Local.xcconfig`. Do not put a real Team ID, certificate, token, or container identifier in Git.

- [ ] **Step 7: Run the focused tests**

Run the Step 2 command again.

Expected: all `ModelContainerFactoryTests` PASS.

- [ ] **Step 8: Commit**

```bash
git add Config .gitignore strength-training strength-training-tests strength-training.xcodeproj
git commit -m "feat: establish local-first Fitness app configuration"
```

### Task 3: Add Metric-First Weight Presentation

**Files:**
- Create: `strength-training/Services/WeightUnitSystem.swift`
- Create: `strength-training-tests/WeightUnitSystemTests.swift`
- Modify: `strength-training/Views/DesignSystem/Components/UpliftStepper.swift`
- Modify: `strength-training/Views/Workout/FocusView.swift`
- Modify: `strength-training/Views/Workout/FocusTargetLogic.swift`
- Modify: `strength-training/Views/Workout/PrevSessionsStripData.swift`
- Modify: `strength-training/Views/Workout/WorkoutSummaryView.swift`
- Modify: `strength-training/Views/Today/TodayStats.swift`
- Modify: `strength-training/Views/Today/ThisWeekCard.swift`
- Modify: `strength-training/Views/Today/YesterdayCard.swift`
- Modify: `strength-training/Views/History/HistoryListView.swift`
- Modify: `strength-training/Views/History/SessionDetailView.swift`
- Modify: `strength-training/Views/Progress/*.swift`
- Modify: `strength-training/Views/Settings/SettingsView.swift`

**Interfaces:**
- Consumes: stored values in pounds (`SetRecord.weightLbs`, algorithm snapshots, backups).
- Produces: `enum WeightUnitSystem: String, CaseIterable { case metric, imperial }`; `static func fromStoredPounds(_:) -> Double`; `static func toStoredPounds(_:) -> Double`; `var symbol: String`; `var inputStep: Double`; `func formatStoredPounds(_:maximumFractionDigits:) -> String`; `static func resolve(rawValue:) -> WeightUnitSystem`.

- [ ] **Step 1: Write failing conversion and preference tests**

Cover 100 lb → 45.3592 kg, 50 kg → 110.231 lb, whole/fraction formatting, metric step `2.5`, imperial step `5`, `test_invalidRawValue_fallsBackToMetric`, and round-trip tolerance of `0.001` lb.

- [ ] **Step 2: Write failing invalid-value tests**

Add `test_displayWeight_sanitizesInvalidValues` for negative, `.nan`, `+.infinity`, and values above the supported UI maximum; require a finite non-negative display value and never the strings `nan` or `inf`.

- [ ] **Step 3: Run `WeightUnitSystemTests` and confirm they fail**

Run: `xcodebuild test -project strength-training.xcodeproj -scheme strength-training -destination 'platform=iOS Simulator,OS=latest,name=iPhone 16 Pro' -only-testing:strength-training-tests/WeightUnitSystemTests CODE_SIGNING_ALLOWED=NO`

Expected: FAIL because `WeightUnitSystem` does not exist.

- [ ] **Step 4: Implement `WeightUnitSystem`**

Use exact conversion constant `2.2046226218` pounds per kilogram. Default invalid preferences to `.metric`. Clamp display inputs to finite `0...10000` before formatting while leaving persisted source data untouched.

- [ ] **Step 5: Add a unit selector to Settings**

Persist `WeightUnitSystem.rawValue` under `weightUnitSystem`; default to `metric`. The selector labels are “公斤” and “磅” through localization keys.

- [ ] **Step 6: Convert all weight and volume presentation boundaries**

Replace hard-coded `lb`, `lbs`, and `pounds` UI output with `WeightUnitSystem`. Convert user stepper input back to stored pounds before assigning `SetRecord.weightLbs`. Keep pure progression algorithms and backup JSON in pounds for compatibility.

- [ ] **Step 7: Update existing assertions to use metric by default and imperial when explicitly selected**

Do not weaken algorithm assertions. Only presentation/accessibility expectations change; add at least one imperial regression assertion for every shared formatter.

- [ ] **Step 8: Run all existing and new unit tests**

Run: `xcodebuild test -project strength-training.xcodeproj -scheme strength-training -destination 'platform=iOS Simulator,OS=latest,name=iPhone 16 Pro' CODE_SIGNING_ALLOWED=NO`

Expected: all test targets PASS with zero unexpected skips.

- [ ] **Step 9: Commit**

```bash
git add strength-training strength-training-tests
git commit -m "feat: add metric-first weight presentation"
```

### Task 4: Add Simplified Chinese Localization and Stable Seed Identity

**Files:**
- Create: `strength-training/Resources/Localizable.xcstrings`
- Create: `strength-training/Models/ExerciseCatalogEntry.swift`
- Create: `strength-training-tests/SeedDataTests.swift`
- Modify: `strength-training/Models/Exercise.swift`
- Modify: `strength-training/Models/SeedData.swift`
- Modify: user-visible SwiftUI views under `strength-training/Views/`
- Modify: `strength-training/ContentView.swift`
- Modify: `strength-training/Info.plist`

**Interfaces:**
- Consumes: existing seeded exercise English names and relationships.
- Produces: `struct ExerciseCatalogEntry { let stableID: String; let fallbackName: String; let localizedNameKey: String; let muscleGroupKey: String; let dayType: DayType; let sortOrder: Int }`; `Exercise.stableCatalogID: String?`; localized display names without using translated text as persistence identity.

- [ ] **Step 1: Write failing stable-seed tests**

Add `test_seedIfNeeded_isIdempotent`, `test_existingSeedReceivesStableCatalogIDWithoutChangingRecords`, and `test_seedCatalogContainsUniqueStableIDs`. Use an in-memory model container.

- [ ] **Step 2: Write failing localization fallback tests**

Add `test_defaultExercise_hasSimplifiedChineseDisplayName` and `test_missingChineseTranslation_fallsBackToEnglishValue`. Assert the existing “Shoulder Press” seed resolves to “肩推” and a synthetic missing key resolves to its English fallback value.

- [ ] **Step 3: Run `SeedDataTests` and confirm failure**

Run: `xcodebuild test -project strength-training.xcodeproj -scheme strength-training -destination 'platform=iOS Simulator,OS=latest,name=iPhone 16 Pro' -only-testing:strength-training-tests/SeedDataTests CODE_SIGNING_ALLOWED=NO`

Expected: FAIL because stable catalog identity and localized resolution are missing.

- [ ] **Step 4: Add stable catalog identity and idempotent migration**

Add optional `stableCatalogID` to `Exercise` so existing stores can migrate additively. Map existing English seed names to stable IDs; never deduplicate by translated display name.

- [ ] **Step 5: Create the English/Simplified Chinese String Catalog**

Include application shell, settings, baseline workout/history/progress screens, accessibility text, errors, units, day types, muscle groups, and the baseline exercise catalog. Keep English as the development-language fallback.

- [ ] **Step 6: Replace hard-coded user-visible strings with localizable resources**

Use `Text` localization keys for static SwiftUI labels and `String(localized:)` for interpolated strings, accessibility output, alerts, and values produced outside a `ViewBuilder`. Date and number formatting must use the current locale rather than hard-coded `en_US`.

- [ ] **Step 7: Declare supported localizations**

Keep English as the development-region fallback, include `zh-Hans`, and verify that a Simplified Chinese device locale renders Chinese while other unsupported locales fall back to English. App Store primary-language selection remains part of Phase 5.

- [ ] **Step 8: Run focused and full test suites**

Run the Step 3 command, followed by the full command from Task 3 Step 8.

Expected: all tests PASS; the seed count is unchanged on the second launch.

- [ ] **Step 9: Commit**

```bash
git add strength-training strength-training-tests strength-training.xcodeproj
git commit -m "feat: add Simplified Chinese localization"
```

### Task 5: Establish the Five-Tab Product Shell and iOS 17 Compatibility

**Files:**
- Create: `strength-training/App/AppTab.swift`
- Create: `strength-training/App/AppShellView.swift`
- Create: `strength-training/Views/Plans/PlansPlaceholderView.swift`
- Create: `strength-training/Views/Courses/CoursesPlaceholderView.swift`
- Create: `strength-training-tests/AppTabTests.swift`
- Modify: `strength-training/ContentView.swift`
- Modify: `strength-training/Views/Workout/PrevSessionsStrip.swift`
- Modify: any source identified by the iOS 17 compile check

**Interfaces:**
- Consumes: existing `TodayView`, `HistoryListView`, `ProgressDashboardView`, `ExerciseLibraryView`, and `SettingsView`.
- Produces: `enum AppTab: String, CaseIterable, Identifiable { case today, plans, courses, data, profile }` with `titleKey` and `systemImage`; `AppShellView` owns `AppTab` selection and five `tabItem` entries compatible with iOS 17.

- [ ] **Step 1: Write failing tab identity tests**

Assert exact order `[.today, .plans, .courses, .data, .profile]`, unique raw values, non-empty SF Symbol names, Simplified Chinese titles “今日、计划、课程、数据、我的”, and English fallbacks.

- [ ] **Step 2: Run `AppTabTests` and confirm failure**

Run: `xcodebuild test -project strength-training.xcodeproj -scheme strength-training -destination 'platform=iOS Simulator,OS=latest,name=iPhone 16 Pro' -only-testing:strength-training-tests/AppTabTests CODE_SIGNING_ALLOWED=NO`

Expected: FAIL because `AppTab` is missing.

- [ ] **Step 3: Implement `AppTab` and `AppShellView`**

Use `TabView(selection:)` with `.tabItem` and `.tag` for iOS 17. Route Today to the existing workout/today experience, Data to history/progress navigation, and Profile to settings. Plans and Courses show localized non-marketing empty states that explicitly identify the next delivery phases.

- [ ] **Step 4: Replace post-iOS-17 calls or guard them**

Replace the newer `Tab(...)` builder. Add availability fallback for `.defaultScrollAnchor(.trailing)` and any other API rejected by an iOS 17 build. Preserve current behavior on newer iOS versions.

- [ ] **Step 5: Compile against the iOS 17 deployment target**

Run: `xcodebuild build -project strength-training.xcodeproj -scheme strength-training -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO IPHONEOS_DEPLOYMENT_TARGET=17.0`

Expected: `** BUILD SUCCEEDED **` with no availability errors.

- [ ] **Step 6: Run focused and full tests**

Run the Step 2 command, followed by the full command from Task 3 Step 8.

Expected: all tests PASS.

- [ ] **Step 7: Commit**

```bash
git add strength-training strength-training-tests
git commit -m "feat: establish Fitness product shell"
```

### Task 6: Add Reproducible macOS Validation and Developer Setup

**Files:**
- Create: `.github/workflows/ios-ci.yml`
- Create: `docs/development/ios-setup.md`
- Modify: `README.md`

**Interfaces:**
- Consumes: the Xcode project and test commands established by Tasks 2–5.
- Produces: pull-request/push CI for a clean simulator build and complete unit suite; exact local setup instructions without credentials.

- [ ] **Step 1: Add the iOS CI workflow**

Trigger on pushes and pull requests. Select an available stable Xcode version, print `xcodebuild -version`, list simulator devices, build with `CODE_SIGNING_ALLOWED=NO`, and run the full test scheme on an available current iPhone simulator. Preserve underlying exit codes.

- [ ] **Step 2: Add `docs/development/ios-setup.md`**

Document Xcode requirements, cloning, optional `Config/Local.xcconfig`, local-only default behavior, simulator test commands, physical-device HealthKit limitation, and the fact that iCloud/TestFlight remain Phase 5 work.

- [ ] **Step 3: Rewrite the README project introduction**

Identify the product as the Fitness project, credit the UpLift base and MIT license, link the approved spec and this plan, and distinguish implemented Phase 1 capabilities from roadmap items.

- [ ] **Step 4: Validate repository hygiene**

Run: `git diff --check && git status --short && rg -n 'WG7BK7C4BG|V8227YC5UT|iCloud\.com\.danielkuhlwein|com\.danielkuhlwein' --glob '!docs/development/upstream.md' --glob '!docs/superpowers/**'`

Expected: `git diff --check` exits 0; only intended files appear; the upstream Team IDs, container, and bundle identifiers do not remain in build configuration.

- [ ] **Step 5: Run the clean build and full test commands from CI**

Expected: `** BUILD SUCCEEDED **`, `** TEST SUCCEEDED **`, and the test report contains non-zero executed tests.

- [ ] **Step 6: Commit**

```bash
git add .github README.md docs/development/ios-setup.md
git commit -m "ci: add reproducible iOS validation"
```

- [ ] **Step 7: Push Phase 1 and verify the GitHub check**

Run: `git push origin HEAD:main`

Expected: the Fitness `main` branch advances and the `ios-ci` workflow completes successfully. If CI fails, diagnose the specific runner/Xcode/project failure, fix it, rerun locally where possible, and push the correction before calling Phase 1 complete.

## Self-Review Record

- Spec coverage: this plan intentionally covers only the foundation. Action media, plans, courses, and release are isolated as Phases 2–5 because each is independently reviewable and testable.
- Step scan: setup steps live inside the deliverable that needs them; code steps name concrete files, types, values, and test commands.
- Type consistency: stored values remain `weightLbs`; every UI consumer uses `WeightUnitSystem`; `AppShellView` uses `AppTab`; `FitnessApp` uses `ModelContainerFactory`.
- Review Focus: every listed failure mode maps to a named test in Tasks 2–4.
- Proportion: the plan defines public seams and acceptance evidence without transcribing implementation bodies.
