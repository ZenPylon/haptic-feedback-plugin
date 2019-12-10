
  Pod::Spec.new do |s|
    s.name = 'HapticFeedback'
    s.version = '0.0.1'
    s.summary = 'Enable haptic feedback in Capacitor'
    s.license = 'MIT'
    s.homepage = 's'
    s.author = 'zenplyon'
    s.source = { :git => 's', :tag => s.version.to_s }
    s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '11.0'
    s.dependency 'Capacitor'
  end