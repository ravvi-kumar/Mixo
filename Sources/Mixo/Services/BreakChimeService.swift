import AppKit

@MainActor
protocol BreakChimePlaying {
    func playBreakEndChime()
}

@MainActor
struct BreakChimeService: BreakChimePlaying {
    private let logger = AppLogger.make("audio")

    func playBreakEndChime() {
        if let sound = NSSound(named: NSSound.Name("Glass")) ??
            NSSound(named: NSSound.Name("Funk")) ??
            NSSound(named: NSSound.Name("Submarine"))
        {
            sound.play()
            logger.info("break_chime_played")
            return
        }

        NSSound.beep()
        logger.info("break_chime_fallback_beep")
    }
}
