require 'rake'

this_dir = Proc.new { File.symlink?(__FILE__) ? File.dirname(File.readlink(__FILE__)) : File.dirname(__FILE__) }
preset_dir = File.expand_path(File.join(this_dir.call, '..', 'defaults'))

FileList[File.join(preset_dir, '*.*')].each do |preset|

    target_file = preset.pathmap('%f').tr('_', '/')
    target_dir = target_file.pathmap('%d')

    desc "Create preset target directory"
    directory target_dir

    desc "Load preset file into project"
    file target_file => FileList[preset, target_dir] do |t|
        puts "Loading preset #{t.name}"
        File.open(t.name, 'w') do |f|
            f.write(File.read(preset))
        end
    end

end

desc "Show available presets"
task :presets do |t, args|

    puts "\# Available presets \n"
    puts FileList[File.join(preset_dir, '*.*')].pathmap('%f').map {|p| ' - ' + p.tr('_', '/')}

end