
//
//  QRCodeScannerView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/4/8.
//
import SwiftUI
import AVFoundation

struct QRCodeScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void
    var onCancel: (() -> Void)?
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.onScan = onScan
        controller.onCancel = onCancel
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}

class ScannerViewController: UIViewController {
    var session: AVCaptureSession?
    var onScan: ((String) -> Void)?
    var onCancel: (() -> Void)?
    
    private let scanLine = UIView()
    private let closeButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermissionAndSetup()
    }
    
    private func checkPermissionAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupCamera()
                    } else {
                        self.showPermissionAlert()
                    }
                }
            }
        default:
            showPermissionAlert()
        }
    }
    
    private func setupCamera() {
        view.backgroundColor = .black
        session = AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session!.canAddInput(input) else { return }
        
        session!.addInput(input)
        
        let output = AVCaptureMetadataOutput()
        if session!.canAddOutput(output) {
            session!.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr]
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session!)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        addScanBox()
        addCloseButton()
        
        session?.startRunning()
    }
    
    private func addScanBox() {
        let scanBoxSize: CGFloat = 250
        let scanBoxFrame = CGRect(x: (view.bounds.width - scanBoxSize) / 2,
                                  y: (view.bounds.height - scanBoxSize) / 2,
                                  width: scanBoxSize,
                                  height: scanBoxSize)
        
        let scanBox = UIView(frame: scanBoxFrame)
        scanBox.layer.borderColor = UIColor.green.cgColor
        scanBox.layer.borderWidth = 2
        view.addSubview(scanBox)
        
        scanLine.frame = CGRect(x: scanBoxFrame.minX, y: scanBoxFrame.minY, width: scanBoxSize, height: 2)
        scanLine.backgroundColor = .red
        view.addSubview(scanLine)
        
        animateScanLine(in: scanBoxFrame)
    }
    
    private func animateScanLine(in frame: CGRect) {
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse]) {
            self.scanLine.frame.origin.y = frame.maxY - 2
        }
    }
    
    private func addCloseButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let xmarkImage = UIImage(systemName: "xmark", withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal)

        closeButton.setImage(xmarkImage, for: .normal)
        closeButton.setTitle(" 關閉", for: .normal) // 前面加空格讓圖跟字分開
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        closeButton.layer.cornerRadius = 10
        closeButton.frame = CGRect(x: 20, y: 50, width: 80, height: 40)
        closeButton.addTarget(self, action: #selector(dismissScanner), for: .touchUpInside)
        view.addSubview(closeButton)
    }
    
    @objc private func dismissScanner() {
        session?.stopRunning()
        onCancel?()
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(title: "相機權限被拒絕", message: "請前往設定開啟相機權限以掃描 QRCode。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           metadataObject.type == .qr,
           let scannedValue = metadataObject.stringValue {
            session?.stopRunning()
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            onScan?(scannedValue)
        }
    }
}
