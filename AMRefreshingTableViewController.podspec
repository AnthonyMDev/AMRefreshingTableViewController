Pod::Spec.new do |s|
  s.platform     = :ios
  s.ios.deployment_target = '8.0'
  s.name         = "AMRefreshingTableViewController"
  s.version      = "1.0.0"
  s.summary      = "A table view controller that loads items from an external (networked) data source."
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Anthony Miller" => "AnthonyMDev@gmail.com" }
  s.homepage     = "https://github.com/AnthonyMDev/AMRefreshingTableViewController"
  s.source   	   = { :git => "https://github.com/anthonymdev/amrefreshingtableviewcontroller.git",
                     :tag => "#{s.version}"}
  s.frameworks = 'UIKit'
  s.requires_arc = true

  s.source_files = "AMRefreshingTableViewController/Core/*.{h,m}"

  s.dependency 'AMPullToRefresh', '~> 1.0'
  s.dependency 'AutoLayoutCells', '~> 0.6'
  s.dependency 'MBProgressHUD', '~> 0.8'
  s.dependency 'UIScrollView-InfiniteScroll', '~> 0.2'

end