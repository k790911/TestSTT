//
//  ViewController.swift
//  TestSTT
//
//  Created by 김재훈 on 2023/01/17.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    @IBOutlet var myTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        speechRecognizer?.delegate = self
        myTextField.text = ""
    }

    @IBAction func btnSpeak(_ sender: UIButton) {
        
        print("1. btn tapped")
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!, resultHandler: { result, error in
            
            print("2. {in handler}")
            
            if result != nil {//self.recognitionTask != nil {
                self.myTextField.text = result?.bestTranscription.formattedString
            }
            
            if let r = result?.isFinal, r == true {
                print("2-1. {in handler, final true}")
                self.endOfSpeech()
            }
        })
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            
            print("3. {audio engine buffer}")
            
            self.recognitionRequest?.append(buffer)
        }
        
        print("4. btn tapped")
        audioEngine.prepare()
        try! audioEngine.start()
    }
    @IBAction func stopRec(_ sender: UIButton) {
        print(#function)
        endOfSpeech()
    }
    
    func endOfSpeech() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
    }
    
}

