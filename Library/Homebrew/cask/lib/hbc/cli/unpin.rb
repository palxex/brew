module Hbc
  class CLI
    class Unpin < AbstractCommand
      def self.run(*args)
        cask_tokens = cask_tokens_from(args)
        raise CaskUnspecifiedError if cask_tokens.empty?
        cask_tokens.each do |cask_token|
          odebug "Pin Cask #{cask_token}"
          cask = Hbc.load(cask_token)
          pin(cask)
        end
      end

      def self.help
        "Pin the given Cask from upgrading"
      end

      def self.pin(cask)
        if cask.pinned?
          cask.unpin
        elsif !cask.installed?
          onoe "#{cask} not installed"
        else
          opoo "#{cask} not pinned"
        end
      end
    end
  end
end
