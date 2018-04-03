//
//  ViewController.swift
//  CapturingVideo
//
//  Created by Michael Yudin on 03.04.2018.
//  Copyright © 2018 Michael Yudin. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    @IBOutlet weak var btCapture: UIButton!
    
    // Input
    var captureVideoDevice: AVCaptureDevice?
    var captureAudioDevice: AVCaptureDevice?
    var captureVideoDeviceInput: AVCaptureDeviceInput?
    var captureAudioDeviceInput: AVCaptureDeviceInput?
    var captureSession: AVCaptureSession?
    var capturePreview: AVCaptureVideoPreviewLayer?
    
    // Output
    var captureMovieFileOutput: AVCaptureMovieFileOutput?
    
    // Logick
    var recording: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSession()
        setupInput()
        setupOutput()
        setupPreview()
    }
    
    // MARK: - Setup Session
    func setupSession() {
        
        // Session
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        captureSession.startRunning()
        if (captureSession.canSetSessionPreset(.high)) {
            captureSession.sessionPreset = .high
        }
    }

    func setupInput() {
        guard let captureSession = captureSession else { return }
        // Input Video
        let discoveryVideoSession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInDualCamera, AVCaptureDevice.DeviceType.builtInTelephotoCamera, AVCaptureDevice.DeviceType.builtInTrueDepthCamera, AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.back)
        captureVideoDevice = discoveryVideoSession.devices.first
        guard let captureVideoDevice = captureVideoDevice else { return }
        do {
            try captureVideoDeviceInput = AVCaptureDeviceInput(device: captureVideoDevice)
        } catch {
            print("\(error.localizedDescription)")
        }
        guard let captureVideoDeviceInput = captureVideoDeviceInput else { return }
        if (captureSession.canAddInput(captureVideoDeviceInput)) {
            captureSession.addInput(captureVideoDeviceInput)
        }
        
        // Input Audio
        let discoveryAudioSession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInMicrophone], mediaType: AVMediaType.audio, position: AVCaptureDevice.Position.unspecified)
        captureAudioDevice = discoveryAudioSession.devices.first
        guard let captureAudioDevice = captureAudioDevice else { return }
        do {
            try captureAudioDeviceInput = AVCaptureDeviceInput(device: captureAudioDevice)
        } catch {
            print("\(error.localizedDescription)")
        }
        guard let captureAudioDeviceInput = captureAudioDeviceInput else { return }
        if (captureSession.canAddInput(captureAudioDeviceInput)) {
            captureSession.addInput(captureAudioDeviceInput)
        }
    }
    
    func setupOutput() {
        guard let captureSession = captureSession else { return }
        // Output
        captureMovieFileOutput = AVCaptureMovieFileOutput()
        guard let captureMovieFileOutput = captureMovieFileOutput else { return }
        if (captureSession.canAddOutput(captureMovieFileOutput)) {
            captureSession.addOutput(captureMovieFileOutput)
        }
        else {
            print("error!")
            return
        }
        if let connection = self.captureMovieFileOutput?.connection(with: .video) {
            if connection.isActive {
                print("OK")
            } else {
                
            }
        }
    }
    
    func setupPreview() {
        guard let captureSession = captureSession else { return }
        // Preview
        capturePreview = AVCaptureVideoPreviewLayer(session: captureSession)
        guard let capturePreview = capturePreview else { return }
        capturePreview.frame = self.view.bounds
        let previewLayer = self.view.layer
        previewLayer.insertSublayer(capturePreview, below: self.btCapture.layer)
    }

    // MARK: - Actions
    @IBAction func btCaptureDidTapped(_ sender: Any) {
        if (!recording) {
            btCapture.setTitle("Stop", for: .normal)
            let fileURL = URL(fileURLWithPath: NSString.path(withComponents: [NSTemporaryDirectory(), "Movie.MOV"]))
            captureMovieFileOutput?.startRecording(to: fileURL, recordingDelegate: self)
        } else {
            btCapture.setTitle("Start", for: .normal)
            captureMovieFileOutput?.stopRecording()
        }
        recording = !recording
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("\(error.localizedDescription)")
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            request?.creationDate = Date()
        }, completionHandler:nil)
    }
    
}

