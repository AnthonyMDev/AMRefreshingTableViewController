platform :ios, "8.0"
inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs.git'
source 'https://bitbucket.org/app-order/ao-private-cocoapods.git'

def import_pods
  pod 'AMPullToRefresh', '~> 1.0'
  pod 'AutoLayoutCells', '~> 0.11.0-beta5'
  pod 'MBProgressHUD', '~> 0.8'
  pod 'UIScrollView-InfiniteScroll', '~> 0.9'
end

target :AMRefreshingTableViewController do
  import_pods
end

target :AMRefreshingTableViewControllerTests do
  import_pods
  
  pod 'Expecta', '~> 0.3'
  pod 'Expecta+LayoutConstraints', '~> 0.1'
  pod 'OCMock', '~> 3.0'
  pod 'XMLDictionary', '~> 1.4'
end
