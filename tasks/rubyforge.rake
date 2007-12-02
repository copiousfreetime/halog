if HAVE_RUBYFORGE then
    require 'rubyforge'
    
    #-----------------------------------------------------------------------
    # Rubyforge additions to the task library
    #-----------------------------------------------------------------------
    namespace :dist do
        desc "Release files to rubyforge"
        task :rubyforge => [:clean, :package] do

            rubyforge = RubyForge.new

            # make sure this release doesn't already exist
            releases = rubyforge.autoconfig['release_ids']
            if releases.has_key?(HALog::SPEC.name) and releases[HALog::SPEC.name][HALog::VERSION] then
                abort("Release #{HALog::VERSION} already exists! Unable to release.")
            end

            config = rubyforge.userconfig
            config["release_notes"]     = HALog::SPEC.description
            config["release_changes"]   = last_changeset
            config["Prefomatted"]       = true

            puts "Uploading to rubyforge..."
            files = FileList[File.join("pkg","#{HALog::SPEC.name}-#{HALog::VERSION}*.*")].to_a
            rubyforge.login
            rubyforge.add_release(HALog::SPEC.rubyforge_project, HALog::SPEC.name, HALog::VERSION, *files)
            puts "done."
            end
    end

    namespace :announce do
        desc "Post news of #{HALog::SPEC.name} to #{HALog::SPEC.rubyforge_project} on rubyforge"
        task :rubyforge do
            subject, title, body, urls = announcement
            rubyforge = RubyForge.new
            rubyforge.login
            rubyforge.post_news(HALog::SPEC.rubyforge_project, subject, "#{title}\n\n#{urls}\n\n#{body}")
            puts "Posted to rubyforge"
        end

    end
end