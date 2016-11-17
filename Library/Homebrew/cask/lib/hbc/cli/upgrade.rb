module Hbc
  class CLI
    class Upgrade < AbstractCommand
      option "--ignore_update_check", :ignore_update_check, false
      option "--force", :force, false
      option "--skip_cask_deps", :skip_cask_deps, false
      option "--require-sha", :require_sha, false

      def run
        casks = Hbc.installed
        cask_tokens = args.any? ? list : Hbc.installed.map(&:to_s)
        outdated=[]
        pinned=[]
        has_autoupgrade=[]
        cask_tokens.each do |cask_token|
          cask = CaskLoader.load(cask_token)
          if cask.outdated?
            if cask.pinned?
              pinned.push(cask_token)
            elsif ignore_update_check? and cask.auto_update?
              has_autoupgrade.push(cask_token)
              opoo "#{cask_token} have built-in auto-update, no need for upgrading through CLI. Use --ignore-update-check to ignore this check"
            else
              outdated.push(cask_token)
            end
          end
        end
        if outdated.empty?
          ohai "No casks to upgrade"
        else
          ohai "Upgrading #{Formatter.pluralize(outdated.length, "outdated casks")}, with result:"
          puts outdated.map { |f| "#{f}" } * ", "
        end
        if pinned.any?
          ohai "Not upgrading #{Formatter.pluralize(pinned.length, "pinned casks")}:"
          puts pinned.map { |f| "#{f}" } * ", "
        end
        if has_autoupgrade.any?
          ohai "Not upgrading #{Formatter.pluralize(has_autoupgrade.length, "build-in auto-upgrade casks, which does no need upgrading through CLI. Use --ignore-update-check to ignore this check")}:"
          puts has_autoupgrade.map { |f| "#{f}" } * ", "
        end
        outdated.each do |cask_token|
            cask = CaskLoader.load(cask_token)
            Installer.new(cask, binaries:       binaries?,
                                verbose:        verbose?,
                                force:          force?,
                                skip_cask_deps: skip_cask_deps?,
                                require_sha:    require_sha?).reinstall
          end
      end

      def self.help
        "upgrade all outdated Casks ( without those pinned )"
      end

      def list
        result_tokens=[]
        args.each do |cask_token|
          begin
            cask = CaskLoader.load(cask_token)
            if cask.installed?
              result_tokens.push cask.token
            else
              opoo "#{cask} is not installed"
            end
          rescue CaskUnavailableError => e
            onoe e
          end
        end

        result_tokens
      end

    end
  end
end
