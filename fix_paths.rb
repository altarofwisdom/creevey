require 'xcodeproj'
project_path = '/Users/yoto/Projects/creevey/creevey.xcodeproj'
project = Xcodeproj::Project.open(project_path)
frameworks_group = project.main_group.groups.find { |g| g.name == 'Frameworks' }

xad_ref = frameworks_group.files.find { |f| f.path =~ /XADMaster\.framework/ }
if xad_ref
  xad_ref.path = 'XADMaster/build/Debug/XADMaster.framework'
  xad_ref.source_tree = '<group>'
end

uni_ref = frameworks_group.files.find { |f| f.path =~ /UniversalDetector\.framework/ }
if uni_ref
  uni_ref.path = 'UniversalDetector/build/Release/UniversalDetector.framework'
  uni_ref.source_tree = '<group>'
end

project.save
puts "Fixed framework paths."
