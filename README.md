# Fitness

A Chinese-first, metric-first native iOS fitness app for beginners, built on [UpLift](https://github.com/danielkuhlwein/strength-training) by Daniel Kuhlwein. The MIT license and original Git history are retained; see [upstream provenance](docs/development/upstream.md).

The foundation provides local SwiftData storage, a five-tab product shell, workout logging, training history and charts, kilograms/pounds preferences, Simplified Chinese with English fallback, stable exercise identities, JSON backup/restore, and an iOS 17 deployment target. Apple Health remains optional and needs physical-device validation.

Plans and Courses currently show placeholders. Action teaching videos, personalized plan generation, guided courses, downloads, iCloud sync and store release are roadmap work, not implemented capabilities.

Open `strength-training.xcodeproj` and select the `strength-training` scheme. Follow [developer setup and simulator validation](docs/development/ios-setup.md). CI builds and tests on macOS without signing credentials.

- [Product design](docs/superpowers/specs/2026-10-27-beginner-fitness-ios-design.md)
- [Phase 1 implementation plan](docs/superpowers/plans/2026-10-27-fitness-ios-foundation.md)
- [MIT license](LICENSE)

ProgressionLab is an upstream macOS algorithm development tool, separate from the iOS product.
