module AresMUSH
  module CoD
    class StatCostCmd
      include CommandHandler

      attr_accessor :stat

      def parse_args
        args = cmd.parse_args(/(?<arg1>[^\/]+)?/)
        self.stat = trim_arg(args.arg1)
      end

      def required_args
        [ self.stat ]
      end

      def handle
        # if self.stat != enactor_name && !CoD.is_st?(enactor)
        #   return CoD.system_emit t('cod.permission_denied'), client
        # end
        # stat = Character.named(self.stat)
        # return CoD.system_emit(t('cod.invalid_character', char: self.stat)) if !stat

      end
    end
  end
end
