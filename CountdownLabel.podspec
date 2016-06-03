Pod::Spec.new do |s|
  s.name         = "CountdownLabel"
  s.version      = '1.1.2'
  s.summary      = 'Simple countdown UILabel with morphing animation, and some useful function.'
  s.homepage     = "https://github.com/suzuki-0000/CountdownLabel"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "suzuki_keishi" => "keishi.1983@gmail.com" }
  s.source       = { :git => "https://github.com/suzuki-0000/CountdownLabel.git", :tag => s.version }
  s.platform     = :ios, "8.4"
  s.source_files = 'CountdownLabel/*.swift'
  s.requires_arc = true
  s.frameworks   = "UIKit"

  s.dependency 'LTMorphingLabel', '~> 0.1.1'
end
