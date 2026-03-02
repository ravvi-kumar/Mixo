import AppKit

@MainActor
protocol BreakChimePlaying {
    func playBreakStartChime()
    func playBreakEndChime()
}

@MainActor
struct BreakChimeService: BreakChimePlaying {
    private let logger = AppLogger.make("audio")

    func playBreakStartChime() {
        if let sound = NSSound(named: NSSound.Name("Ping")) ??
            NSSound(named: NSSound.Name("Hero")) ??
            NSSound(named: NSSound.Name("Pop"))
        {
            sound.play()
            logger.info("break_start_chime_played")
            return
        }

        NSSound.beep()
        logger.info("break_start_chime_fallback_beep")
    }

    func playBreakEndChime() {
        if let sound = NSSound(named: NSSound.Name("Glass")) ??
            NSSound(named: NSSound.Name("Funk")) ??
            NSSound(named: NSSound.Name("Submarine"))
        {
            sound.play()
            logger.info("break_end_chime_played")
            return
        }

        NSSound.beep()
        logger.info("break_end_chime_fallback_beep")
    }
}
