
Pod::Spec.new do |s|

s.name         = 'toast'
s.version      = '1.0.0'
s.summary      = 'a component of toast on iOS'
s.homepage     = 'https://github.com/kk07self/toast'
s.description  = <<-DESC
It is a component for ios toast, written by Swift.
DESC
s.license      = 'MIT'
s.authors      = {'Kirk' => 'kk.07.self@gmail.com'}
s.platform     = :ios, '8.0'
s.source       = {:git => 'https://github.com/kk07self/kk_refresh.git', :tag => s.version}
s.source_files = 'toast/toast/*.swift'
s.resource_bundle = {
    'toast' => ['toast/toast/resource/*.png']
}
s.requires_arc = true

end

