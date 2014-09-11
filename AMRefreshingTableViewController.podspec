Pod::Spec.new do |s|
  s.platform     = :ios
  s.ios.deployment_target = '7.0'
  s.name         = "AMRefreshingTableViewController"
  s.version      = "0.1.0"
  s.summary      = "A table view controller that displays a list of items recieved from an external data source, utilizing pull to refresh and infinite scroll loading."
  s.homepage     = "http://redmine.app-order.com"
  s.license      = { :type => "MIT", :file => "LICENSEß" }
  s.author       = { "Anthony Miller" => "AnthonyMDev@gmail.com" }
  s.source   	 = { :git => "https://bitbucket.org/anthonymdev/amrefreshingtableviewcontroller.git",
                     :tag => "#{s.version}"}
  s.frameworks = 'UIKit'
  s.requires_arc = true

  s.dependency 'AOBaseControllers', '~> 2.0'
  s.dependency 'AOPullToRefresh', '~> 0.2'
  s.dependency 'AutoLayoutCells', '~> 0.2'
  s.dependency 'MBProgressHUD', '~> 0.8'
  s.dependency 'MBProgressHUD+AOTapToCancel', '~> 0.1'
  s.dependency 'UIImage+ColorPlaceholder', '~> 1.0'
  s.dependency 'UIView+AORefreshFont', '~> 1.0'
  s.dependency 'UIScrollView-InfiniteScroll', '~> 0.2'

  s.resource_bundles = {'AMRefreshingTableViewController' => ['AMRefreshingTableViewController/ResourcesBundle/*/*']}
  s.source_files = "AMRefreshingTableViewController/*.{h,m}"
end