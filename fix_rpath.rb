require 'xcodeproj'
project_path = '/Users/yoto/Projects/creevey/creevey.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

target.build_configurations.each do |config|
  rpaths = config.build_settings['LD_RUNPATH_SEARCH_PATHS'] || ['$(inherited)']
  rpaths = [rpaths] if rpaths.is_a?(String)
  rpaths << '@executable_path/../Frameworks'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = rpaths.uniq
end
project.save
