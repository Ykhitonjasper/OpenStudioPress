import Foundation

enum LaunchTier: Equatable {
    case cold
    case warm

    var showsBrandedSplash: Bool {
        if case .cold = self { return true }
        return false
    }

    var showsWarmOverlay: Bool {
        if case .warm = self { return true }
        return false
    }

    var loaderMin: TimeInterval {
        switch self {
        case .cold: Timeouts.coldLoaderMin
        case .warm: Timeouts.warmOverlayMin
        }
    }

    var launchBudget: TimeInterval {
        switch self {
        case .cold: Timeouts.coldLaunchBudget
        case .warm: Timeouts.warmLaunchBudget
        }
    }

    var loaderMax: TimeInterval { launchBudget }

    static func resolve(cachedURL: String?, launchCount: Int = 0) -> LaunchTier {
        cachedURL != nil ? .warm : .cold
    }
}

enum LaunchLoaderStage: String, Equatable {
    case idle
    case starting
    case deciding
    case loadingRoute
    case preparingContent
    case finishing
    case complete
}

enum LaunchSplashCopy {
    static func message(for progress: Double) -> String {
        switch progress {
        case ..<0.40:
            return "Laying out the folio..."
        case ..<0.78:
            return "Inking the plates..."
        case ..<1.0:
            return "Almost ready..."
        default:
            return "Ready"
        }
    }
}
