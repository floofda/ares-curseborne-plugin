module AresMUSH
  module CoD
    class StatCheckCmd
      include CommandHandler

      attr_accessor :target, :stat

      def parse_args
        args = cmd.parse_args(/(?<arg1>[^\/]+)?\/?(?<arg2>[^\=]+)?/)
        self.target = trim_arg(args.arg1)
        self.stat = trim_arg(args.arg2)
      end

      def required_args
        [ self.target ]
      end

      def handle
        if self.target != enactor_name && !CoD.is_st?(enactor)
          return CoD.system_emit t('cod.permission_denied'), client
        end
        target = Character.named(self.target)
        return CoD.system_emit(t('cod.invalid_character', char: self.target)) if !target

        if !self.stat
          target.sheet.merits.each { |m|
            stat = CoD.get_stat_from_config CoD.merits(target.sheet.template), m.name

            next CoD.system_emit(t('cod.invalid_stat', stat: self.stat), client) if !stat
            next CoD.system_emit(t('cod.no_reqs_found_stat', stat: stat['name']), client, nil, :info) if !stat['reqs']

            met = CoD.parse_expression(stat['reqs'], target.sheet)
            if !met
              CoD.system_emit t('cod.reqs_not_met_for_stat', stat: stat['name'], reqs: stat['reqs']), client
            else
              CoD.system_emit t('cod.reqs_met_for_stat', stat: stat['name']), client, nil, :info
            end
          }
          return
        end

        stat = CoD.get_stat_from_config CoD.merits(target.sheet.template), self.stat
        return CoD.system_emit(t('cod.invalid_stat', stat: self.stat), client) if !stat
        return CoD.system_emit(t('cod.no_reqs_found_stat', stat: stat['name']), client, nil, :info) if !stat['reqs']

        met = CoD.parse_expression(stat['reqs'], target.sheet)

        if !met
          CoD.system_emit t('cod.reqs_not_met_for_stat', stat: stat['name'], reqs: stat['reqs']), client
        else
          CoD.system_emit t('cod.reqs_met_for_stat', stat: stat['name']), client, nil, :info
        end
      end
    end
  end
end
