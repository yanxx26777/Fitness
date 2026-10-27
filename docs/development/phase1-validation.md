# Phase 1 local validation — 2026-10-28

Local source restoration and verification are complete. GitHub push and remote CI verification are pending local GitHub authentication. Plans and Courses remain explicit placeholders for later phases.

- Toolchain: Xcode 27.1, Swift 6.4, arm64 Mac.
- Deployment target: iOS 17.0; clean generic iOS Simulator build passed.
- Runtime: installed iPhone Duo simulator, iOS 27.1.
- Final result bundle: `/tmp/FitnessFinalCheck.xcresult`.
- Final test report: **99 passed, 0 failed, 0 skipped** (97 unit tests and 2 UI tests).
- Hygiene: `git diff --check` passed; upstream Team IDs, bundle identifiers, and CloudKit identifiers are absent from current build configuration.

The UI tests cover Chinese navigation and placeholders, localized exercise catalog, stable day-type selection in Add Exercise, backup share presentation, metric set entry, hidden navigation during training, personal-record celebration dismissal, workout summary, and return to the shell. Unit regressions cover non-finite/extreme historical weights, signed decreases, immediate Chinese catalog identity after backup restore, preserved stored pounds and history relationships, local-only model configuration, seed idempotency, and English fallback.

An independent read-only review found three important issues: unsafe workout input formatting, missing negative signs, and restore-time catalog identity. Each received a failing regression test and a fix before the final green run. An additional Chinese selector binding regression was reproduced by UI test and fixed by retaining raw enum identity in the binding.

## Implementation decisions

1. Use the user-requested local Fitness checkout and main branch. This follows the explicit local-creation/push handoff; it gives no additional branch isolation.
2. Use the installed iPhone Duo/iOS 27.1 simulator because the requested iPhone 16 Pro runtime/device combination is unavailable. iOS 17 API availability is checked at compilation, but iOS 17 runtime behavior and physical-device HealthKit still need validation before release.
3. Keep cumulative volume separate from the single-weight 10,000 lb presentation bound. Legitimate training totals can exceed that bound; anomalous finite totals may display very large values rather than being truncated.
4. Restore interdependent foundation changes in one tested implementation commit. This keeps iOS 17 configuration, shell and HealthKit availability changes buildable together, at the cost of coarser rollback granularity.

No production signing, iCloud container, TestFlight deployment or App Store submission is configured.
