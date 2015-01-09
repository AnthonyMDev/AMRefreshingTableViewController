platform :ios, "7.0"
inhibit_all_warnings!

def import_pods
  pod 'AMPullToRefresh', '~> 1.0'
  pod 'AutoLayoutCells', '~> 0.6'
  pod 'MBProgressHUD', '~> 0.8'
  pod 'UIScrollView-InfiniteScroll', '~> 0.2'
end

target :AMRefreshingTableViewController do
  import_pods
end

target :AMRefreshingTableViewControllerTests do
  pod 'Expecta', '~> 0.3'
  pod 'Expecta+LayoutConstraints', '~> 0.1'
  pod 'OCMock', '~> 3.0'
  pod 'XMLDictionary', '~> 1.4'
end
