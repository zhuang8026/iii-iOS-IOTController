# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

platform :ios, '12.0'  # 建議升級最低 iOS 版本

target 'Sttptech_energy' do
  use_frameworks! :linkage => :static  # 避免與某些 Pods 不兼容的問題
  use_modular_headers! # ✅ 加入這行

  # 明確指定 CocoaMQTT 版本
  pod 'CocoaMQTT', '2.1.6'

  target 'Sttptech_energyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Sttptech_energyUITests' do
    # Pods for testing
  end
end

