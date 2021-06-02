//
//  MainViewController.swift
//  ARVoiceRemote
//
//  Created by Artyom Mihailovich on 5/31/21.
//

import UIKit
import ARKit
import SnapKit
import RealityKit
import Speech

final class MainViewController: UIViewController {
    
    enum Language: String {
        case en = "en-US"
        ///.... case ru = "ru-RU"
    }
    
    private let moveDuration = 5.0
    private var entity: Entity?
    
    private var transform = Transform()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: Language.en.rawValue))
    private let speechRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    private var speechTask = SFSpeechRecognitionTask()
    
    private let audioEngine = AVAudioEngine()
    private var audioSession: AVAudioSession?
    
    private lazy var arView = ARView().do {
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                       action: #selector(handleTap(recognizer:))))
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupARConfiguration()
        obtainEntity()
        obtainPeopleOcclusion()
        startRecognition()
    }
    
    private func setupARConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
    }
    
    private func setupSubviews() {
        view.addSubview(arView)
        
        arView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func obtainEntity() {
        do {
            entity = try ModelEntity.load(named: "Drone")
            entity?.setScale(SIMD3(repeating: 0.03), relativeTo: nil)
            entity?.generateCollisionShapes(recursive: true)
        } catch {
            print("DEBUGGER: - USDZ model not been loaded.")
        }
    }
    
    private func playSound(entity: Entity?) {
        let audioPath = "DroneSound.mp3"
        do {
            let resource = try AudioFileResource.load(named: audioPath,
                                                      in: nil, inputMode: .spatial,
                                                      loadingStrategy: .preload,
                                                      shouldLoop: true)
            
            let audioController = entity?.prepareAudio(resource)
            audioController?.play()
        } catch {
            print("DEBUGGER: - Sound not been loaded")
        }
    }
    
    private func obtainPeopleOcclusion() {
         guard let configuration = arView.session.configuration as? ARWorldTrackingConfiguration else {
             fatalError("DEBUGGER: - Unexpectedly failed to get the configuration.")
         }
         guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
             fatalError("DEBUGGER: - People occlusion is not supported on this device.")
         }
         configuration.frameSemantics.insert(.personSegmentationWithDepth)
         arView.session.run(configuration)
    }

    private func placeObject(entity: Entity, position: SIMD3<Float>) {
        let anchor = AnchorEntity(world: position)
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
    }

    private func obtainAnimation(with duration: Double, entity: Entity?) {
        if let animation = entity?.availableAnimations.first {
            entity?.playAnimation(animation.repeat(duration: duration),
                                  transitionDuration: 0.5,
                                  startsPaused: false )
        } else {
            print("DEBUGGER: - Animation not been loaded from USDZ file.")
        }
    }
    
    private func move(to direction: String) {
        switch direction {
        case "play":
            transform.translation = (self.entity?.transform.translation)! + simd_float3(x: 0, y: 0, z: -20)
            obtainAnimation(with: 20, entity: entity)
            playSound(entity: entity)
        case "forward":
            transform.translation = (entity?.transform.translation)! + simd_float3(x: 0, y: 0, z: 40)
            entity?.move(to: transform, relativeTo: entity!, duration: moveDuration)
            obtainAnimation(with: 20, entity: entity)
            playSound(entity: entity)
        case "up":
            transform.translation = (entity?.transform.translation)! + simd_float3(x: 0, y: 20, z: 0)
            entity?.move(to: transform, relativeTo: entity!, duration: moveDuration)
            obtainAnimation(with: 20, entity: entity)
            playSound(entity: entity)
        case "down":
            transform.translation = (entity?.transform.translation)! + simd_float3(x: 0, y: -20, z: 0)
            entity?.move(to: transform, relativeTo: entity!, duration: moveDuration)
            obtainAnimation(with: 20, entity: entity)
            playSound(entity: entity)
        case "back":
            transform.translation = (entity?.transform.translation)! + simd_float3(x: 0, y: 0, z: -40)
            entity?.move(to: transform, relativeTo: entity!, duration: moveDuration)
            obtainAnimation(with: 20, entity: entity)
            playSound(entity: entity)
        case "left":
            transform.rotation = simd_quatf(angle: .radians, axis:  SIMD3<Float>(0,-0.45,0))
            entity?.move(to: transform, relativeTo: entity!, duration: moveDuration)
            obtainAnimation(with: 20, entity: entity)
            playSound(entity: entity)
        case "right":
            transform.rotation = simd_quatf(angle: .radians, axis:  SIMD3<Float>(0,0.45,0))
            entity?.move(to: transform, relativeTo: entity!, duration: moveDuration)
            obtainAnimation(with: 20, entity: entity)
        case "stop":
            transform.translation = (entity?.transform.translation)! + simd_float3(x: 0, y: -23, z: 0)
            entity?.move(to: transform, relativeTo: entity!, duration: moveDuration)
            obtainAnimation(with: 3, entity: entity)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.entity?.stopAllAnimations()
                self.entity?.stopAllAudio()
            }
        default:
            print("DEBUGER: - Voice movable comands aren't recognized.")
        }
    }
    
    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        let rayResults = arView.raycast(from: location,
                                     allowing: .estimatedPlane,
                                     alignment: .horizontal)
        
        if let rayResult = rayResults.first {
            let position = simd_make_float3(rayResult.worldTransform.columns.3)
            placeObject(entity: entity!, position: position)
        }
    }
    
}

extension MainViewController {
    private func request() {
        SFSpeechRecognizer.requestAuthorization {
            switch $0 {
            case .authorized:
                print("Speech Recognizer - been Authorized!")
            case .denied:
                print("Speech Recognizer - been Denied!")
            case .notDetermined:
                print("Speech Recognizer - not Determined!")
            case .restricted:
                print("Speech Recognizer - been Restricted!")
            @unknown default:
                fatalError("FatalError! - Speech Recognizer - request autorization!")
            }
        }
    }
    
    private func audioRecord() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: format) { [unowned self] buffer, _ in
            speechRecognitionRequest.append(buffer)
        }
        
        do {
            try audioSession?.setCategory(.record,
                                          mode: .measurement,
                                          options: .duckOthers)
            
            try audioSession?.setActive(true,
                                        options: .notifyOthersOnDeactivation)
            
            audioEngine.prepare()
            try audioEngine.start()
        } catch  {
            print("DEBUGGER: - Speech Recognizer - Audio Session cannot been done!")
        }
    }
    
    private func obtainSpeechRecognize() {
        guard let speechRecognizer = speechRecognizer else { return }
        var count = 0
        
        speechTask = speechRecognizer.recognitionTask(with: speechRecognitionRequest, resultHandler: { result, error in
            count = count + 1
            
            switch count {
            case let x where x == 1:
                guard let result = result else { return }
                let recognizedText = result.bestTranscription.segments.last?.substring
                self.move(to: recognizedText!)
            case let x where x >= 3:
                count = 0
            default:
                break
            }
       })
    }
    
    private func startRecognition() {
        request()
        audioRecord()
        obtainSpeechRecognize()
    }
}
