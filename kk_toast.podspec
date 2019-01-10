
Pod::Spec.new do |s|

s.name         = 'kk_toast'
s.version      = '1.0.1'
s.summary      = 'a component of toast on iOS'
s.homepage     = 'https://github.com/kk07self/kk_toast'
s.description  = <<-DESC
It is a component for ios toast, written by Swift.
DESC
s.license      = 'MIT'
s.authors      = {'Kirk' => 'kk.07.self@gmail.com'}
s.platform     = :ios, '9.0'
s.source       = {:git => 'https://github.com/kk07self/kk_toast.git', :tag => s.version}
s.source_files = 'toast/toast/*'
s.resource_bundle = {
    'toast' => ['toast/toast/resource/*.png']
}
s.requires_arc = true

end

