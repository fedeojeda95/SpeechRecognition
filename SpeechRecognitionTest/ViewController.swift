//
//  ViewController.swift
//  SpeechRecognitionTest
//
//  Created by Federico Ojeda on 11/5/18.
//  Copyright © 2018 Federico Ojeda. All rights reserved.
//

import Speech
import UIKit

fileprivate struct Constants {
  static let startListeningMessage = "Start listening"
  static let stopListeningMessage = "Stop listening"
  
  struct Commands {
    static let top = "top"
    static let bottom = "bottom"
    static let right = "right"
    static let left = "left"
  }
}

class ViewController: UIViewController {

  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var rightView: UIView!
  @IBOutlet weak var bottomView: UIView!
  @IBOutlet weak var leftView: UIView!
  @IBOutlet weak var actionButton: UIButton!
  
  let audioEngine = AVAudioEngine()
  let speechRecognizer = SFSpeechRecognizer()
  let request = SFSpeechAudioBufferRecognitionRequest()
  var recognitionTask: SFSpeechRecognitionTask?
  
  var isRecording = false

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopRecording()
  }
  
  @IBAction func startListening() {
    if isRecording {
      stopRecording()
      actionButton.setTitle(Constants.startListeningMessage, for: .normal)
    } else {
      askForAuthorizationIfNeeded()
      actionButton.setTitle(Constants.stopListeningMessage, for: .normal)
    }
  }
  
  private func askForAuthorizationIfNeeded() {
    SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
      guard let self = self else { return }
      
      switch authStatus {
      case .authorized:
        do {
          try self.startRecording()
        } catch let error {
          print("A problem has ocurred: \(error.localizedDescription)")
        }
      case .denied, .restricted, .notDetermined:
        print("Can't use speech recognition")
      }
    }
  }
  
  private func startRecording() throws {
    isRecording = true
    try startAudioEngine()
    
    recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, _ in
      guard
        let self = self,
        let transcription = result?.bestTranscription,
        let latestTranscription = transcription.segments.last
      else {
        return
      }
      
      self.selectSquare(text: latestTranscription.substring.lowercased())
    }
  }
  
  private func startAudioEngine() throws {
    let node = audioEngine.inputNode
    let recordingFormat = node.outputFormat(forBus: 0)
    
    node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
      self?.request.append(buffer)
    }
    
    audioEngine.prepare()
    try audioEngine.start()
  }
  
  private func selectSquare(text: String) {
    print(text)
    
    switch text {
    case Constants.Commands.right:
      showRight()
      break
    case Constants.Commands.left:
      showLeft()
      break
    case Constants.Commands.top:
      showTop()
      break
    case Constants.Commands.bottom:
      showBottom()
      break
    default:
      hideAll()
      break
    }
  }
  
  private func stopRecording() {
    isRecording = false
    audioEngine.stop()
    request.endAudio()
    recognitionTask?.cancel()
    audioEngine.inputNode.removeTap(onBus: 0)
    showAll()
  }

  private func showTop() {
    topView.isHidden = false
    rightView.isHidden = true
    leftView.isHidden = true
    bottomView.isHidden = true
  }
  
  private func showBottom() {
    topView.isHidden = true
    rightView.isHidden = true
    leftView.isHidden = true
    bottomView.isHidden = false
  }
  
  private func showRight() {
    topView.isHidden = true
    rightView.isHidden = false
    leftView.isHidden = true
    bottomView.isHidden = true
  }
  
  private func showLeft() {
    topView.isHidden = true
    rightView.isHidden = true
    leftView.isHidden = false
    bottomView.isHidden = true
  }
  
  private func hideAll() {
    topView.isHidden = true
    rightView.isHidden = true
    leftView.isHidden = true
    bottomView.isHidden = true
  }
  
  private func showAll() {
    topView.isHidden = false
    rightView.isHidden = false
    leftView.isHidden = false
    bottomView.isHidden = false
  }
  
}

