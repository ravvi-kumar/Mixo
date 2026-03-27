import CoreAudio
import Foundation

protocol MediaActivityServicing {
    func isMediaPlaybackLikelyActive() -> Bool
}

struct MediaActivityService: MediaActivityServicing {
    func isMediaPlaybackLikelyActive() -> Bool {
        guard let outputDeviceID = defaultOutputDeviceID() else {
            return false
        }
        return isDeviceRunningSomewhere(outputDeviceID: outputDeviceID)
    }

    private func defaultOutputDeviceID() -> AudioObjectID? {
        var deviceID = AudioObjectID(0)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var propertySize = UInt32(MemoryLayout<AudioObjectID>.size)

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &propertySize,
            &deviceID
        )

        guard status == noErr, deviceID != kAudioObjectUnknown else {
            return nil
        }
        return deviceID
    }

    private func isDeviceRunningSomewhere(outputDeviceID: AudioObjectID) -> Bool {
        var runningFlag: UInt32 = 0
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceIsRunningSomewhere,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var propertySize = UInt32(MemoryLayout<UInt32>.size)

        let status = AudioObjectGetPropertyData(
            outputDeviceID,
            &address,
            0,
            nil,
            &propertySize,
            &runningFlag
        )

        guard status == noErr else {
            return false
        }
        return runningFlag != 0
    }
}
