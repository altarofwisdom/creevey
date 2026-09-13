require 'xcodeproj'

project_path = '/Users/yoto/Projects/creevey/creevey.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets.first

# Add ArchiveManager.h and .m
group = project.main_group.groups.find { |g| g.name == 'Source' } || project.main_group
h_ref = group.new_reference('ArchiveManager.h')
m_ref = group.new_reference('ArchiveManager.m')

target.add_file_references([m_ref])

# Frameworks to link
xadmaster_framework = '../XADMaster/build/Debug/XADMaster.framework'
unidetector_framework = '../UniversalDetector/build/Release/UniversalDetector.framework'

frameworks_group = project.main_group.groups.find { |g| g.name == 'Frameworks' } || project.main_group.new_group('Frameworks')
xad_ref = frameworks_group.new_reference(xadmaster_framework)
uni_ref = frameworks_group.new_reference(unidetector_framework)

target.frameworks_build_phases.add_file_reference(xad_ref)
target.frameworks_build_phases.add_file_reference(uni_ref)

# Add Framework Search Paths
target.build_configurations.each do |config|
  search_paths = config.build_settings['FRAMEWORK_SEARCH_PATHS'] || ['$(inherited)']
  search_paths = [search_paths] if search_paths.is_a?(String)
  search_paths << '"$(SRCROOT)/XADMaster/build/Debug"'
  search_paths << '"$(SRCROOT)/UniversalDetector/build/Release"'
  config.build_settings['FRAMEWORK_SEARCH_PATHS'] = search_paths.uniq
end

project.save
puts "Added ArchiveManager.m and linked frameworks successfully."
