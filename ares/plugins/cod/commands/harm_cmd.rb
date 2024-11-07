module AresMUSH
  module CoD
    class HarmCmd
      include CommandHandler

      attr_accessor :target, :amount, :msg

      def parse_args
        args = cmd.parse_args(/(?<arg1>[^\/]+)?\/?(?<arg2>[^\=]+)?\=?(?<arg3>.+)?/)
        if CoD.is_numeric? args.arg1
          self.target = enactor_name
          self.amount = integer_arg(args.arg1)
        else
          self.target = args.arg1
          self.amount = integer_arg(args.arg2)
        end
        self.msg = args.arg3
      end

      def required_args
        [ self.amount ]
      end

      def handle
        if self.target != enactor_name && !CoD.is_st?(enactor)
          return CoD.system_emit t('cod.permission_denied'), client
        end

        opts = { enactor: enactor, char: self.target, value: -self.amount, type: cmd.switch }
        msg, error = CoD.build_adjust_health_emit(opts)
        return CoD.system_emit(error, client) if error
        CoD.emit_message msg, client, enactor_room
      end
    end
  end
end
