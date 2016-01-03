Pod::Spec.new do |s|
  s.name         = "HMQRCodeScanner"
  s.version      = "1.0.5"
  s.summary      = "包含 UI 界面的轻量级二维码扫描及生成框架"
  s.homepage     = "https://github.com/liufan321/HMQRCodeScanner"
  s.license      = "MIT"
  s.author       = { "Fan Liu" => "liufan321@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/liufan321/HMQRCodeScanner.git", :tag => s.version }
  s.source_files = "HMQRCodeScanner/QRCode/*.{h,m}"
  s.resources    = "HMQRCodeScanner/QRCode/HMScanner.bundle"
  s.framework    = "AVFoundation"
  s.requires_arc = true
end
