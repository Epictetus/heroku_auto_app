module Heroku::Command
  class Base
    alias_method :original_extract_app_in_dir, :extract_app_in_dir
    def extract_app_in_dir(dir)
      begin
        original_extract_app_in_dir(dir)
      rescue Heroku::Command::CommandFailed => e
        if remotes = git_remotes(dir) && upstream = extract_current_upstream
          remotes[upstream]
        else
          raise e
        end
      end
    end

    private
    def extract_current_upstream
      current_branch = git("branch -v -v").split("\n").find { |l| l[0] = "*" }
      if current_branch.match(/\[(?<remote>[^\/]*)\/(?<branch>[^\]:]*).*\]/) && $~[:branch] == 'master'
        $~[:remote]
      end
    end
  end
end
