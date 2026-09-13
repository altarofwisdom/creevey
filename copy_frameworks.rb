require 'xcodeproj'
project_path = '/Users/yoto/Projects/creevey/creevey.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

frameworks_group = project.main_group.groups.find { |g| g.name == 'Frameworks' }
xad_ref = frameworks_group.files.find { |f| f.path =~ /XADMaster\.framework/ }
uni_ref = frameworks_group.files.find { |f| f.path =~ /UniversalDetector\.framework/ }

copy_phase = target.build_phases.find { |p| p.is_a?(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase) && p.symbol_dst_subfolder_spec == :frameworks }
unless copy_phase
  copy_phase = target.project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
  copy_phase.symbol_dst_subfolder_spec = :frameworks
  target.build_phases << copy_phase
end

unless copy_phase.files.map(&:file_ref).include?(xad_ref)
  build_file = copy_phase.add_file_reference(xad_ref)
  build_file.settings = { 'ATTRIBUTES' => ['CodeSignOnCopy', 'RemoveHeadersOnCopy'] }
end

unless copy_phase.files.map(&:file_ref).include?(uni_ref)
  build_file = copy_phase.add_file_reference(uni_ref)
  build_file.settings = { 'ATTRIBUTES' => ['CodeSignOnCopy', 'RemoveHeadersOnCopy'] }
end

project.save
puts "Added copy phase for frameworks."
