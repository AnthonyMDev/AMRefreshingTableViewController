Pod::Spec.new do |s|
  s.platform     = :ios
  s.ios.deployment_target = '7.0'
  s.name         = "AMRefreshingTableViewController"
  s.version      = "0.1.0"
  s.summary      = "A table view controller that loads items from an external (networked) data source."
  s.license      = { :type => "MIT", :file => "LICENSEß" }
  s.author       = { "Anthony Miller" => "AnthonyMDev@gmail.com" }
  s.homepage     = "https://github.com/AnthonyMDev/AMRefreshingTableViewController"
  s.source   	   = { :git => "https://github.com/anthonymdev/amrefreshingtableviewcontroller.git",
                     :tag => "#{s.version}"}
  s.frameworks = 'UIKit'
  s.requires_arc = true

  s.dependency 'AMPullToRefresh', '~> 1.0'
  s.dependency 'AutoLayoutCells', '~> 0.2'
  s.dependency 'MBProgressHUD', '~> 0.8'
  s.dependency 'UIImage+ColorPlaceholder', '~> 1.0'
  s.dependency 'UIScrollView-InfiniteScroll', '~> 0.2'

  s.resource_bundles = {'AMRefreshingTableViewController' => ['AMRefreshingTableViewController/ResourcesBundle/*/*']}
  s.source_files = "AMRefreshingTableViewController/*.{h,m}"
end