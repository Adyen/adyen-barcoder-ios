Pod::Spec.new do |s|
  s.name             = 'AdyenBarcoder'
  s.version          = '1.4.2'
  s.summary          = 'Use Verifone Barcode reader over MFi'

  s.description      = <<-DESC
Library to connect and use Verifone Barcode reader over MFi connection
                       DESC

  s.homepage         = 'https://github.com/Adyen/adyen-barcoder-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Taras Kalapun' => 't.kalapun@gmail.com' }
  s.source           = { :git => 'https://github.com/Adyen/adyen-barcoder-ios.git', :tag => s.version.to_s }

  s.swift_version = '4.2'
  s.ios.deployment_target = '8.0'

  s.source_files = 'AdyenBarcoder/*.swift'
end
