import SoundAnalysis
import AVFoundation
import CoreML

class SoundClassifier: NSObject, ObservableObject {
    private let audioEngine = AVAudioEngine()
    private var analyzer: SNAudioStreamAnalyzer!
    private let inputFormat: AVAudioFormat
    private var resultsObserver: SNResultsObserving!

    @Published var detectedLabel: String = ""
    var onRisingBeepDetected: (() -> Void)?

    override init() {
        inputFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        super.init()

        analyzer = SNAudioStreamAnalyzer(format: inputFormat)

        guard let model = try? VarioSound_Classification_1(configuration: MLModelConfiguration()).model,
              let request = try? SNClassifySoundRequest(mlModel: model) else {
            fatalError("error loading ml model")
        }

        resultsObserver = SoundResultsObserver { label in
            DispatchQueue.main.async {
                self.detectedLabel = label
                if label == "Rise" {
                    self.onRisingBeepDetected?()
                }
            }
        }

        do {
            try analyzer.add(request, withObserver: resultsObserver)
        } catch {
            print("Analyzer request error: \(error)")
        }
    }

    func startListening() {
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, time in
            self.analyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
        }

        do {
            try audioEngine.start()
            print("Audio engine started.")
        } catch {
            print("Starting error \(error)")
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}

class SoundResultsObserver: NSObject, SNResultsObserving {
    private let callback: (String) -> Void

    init(callback: @escaping (String) -> Void) {
        self.callback = callback
    }

    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classification = result as? SNClassificationResult,
              let topResult = classification.classifications.first,
              topResult.confidence > 0.85 else { return }

        callback(topResult.identifier)
    }
}


