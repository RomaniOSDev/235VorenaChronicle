import UIKit
import AudioToolbox

enum HapticManager {
    static func lightTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func mediumTap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

enum SoundManager {
    static func playTick() {
        AudioServicesPlaySystemSound(1003)
    }

    static func playSuccess() {
        AudioServicesPlaySystemSound(1057)
    }

    static func playSave() {
        AudioServicesPlaySystemSound(1104)
    }

    static func playThemeSave() {
        AudioServicesPlaySystemSound(1519)
    }

    static func playVibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

enum FeedbackManager {
    static func buttonTap() {
        HapticManager.lightTap()
        SoundManager.playTick()
    }

    static func saveSuccess() {
        HapticManager.mediumTap()
        SoundManager.playSuccess()
        HapticManager.success()
    }

    static func themeSaved() {
        HapticManager.mediumTap()
        SoundManager.playThemeSave()
    }

    static func annotationSaved() {
        HapticManager.mediumTap()
        SoundManager.playSave()
    }

    static func favouriteToggled() {
        HapticManager.mediumTap()
        SoundManager.playVibrate()
    }

    static func achievementUnlocked() {
        HapticManager.success()
        SoundManager.playSuccess()
    }

    static func validationError() {
        HapticManager.warning()
    }
}
