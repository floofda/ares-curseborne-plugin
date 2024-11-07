module AresMUSH
  module CoD
    class XpCmd
      include CommandHandler

      attr_accessor :target, :amount, :msg

      def parse_args
        args = cmd.parse_args(/(?<arg1>[^\/]+)?\/?(?<arg2>[^\=]+)?\=?(?<arg3>.+)?/)
        if CoD.is_numeric? args.arg1
          self.target = enactor_name
          self.amount = args.arg1 ? trim_arg(args.arg1).to_f : nil
        else
          self.target = args.arg1
          self.amount = args.arg1 ? trim_arg(args.arg2).to_f : nil
        end
        self.target = enactor_name if !args.arg1
        self.msg = args.arg3
      end

      def handle
        if cmd.switch && !CoD.is_st?(enactor)
          return CoD.system_emit t('cod.permission_denied'), client
        end

        amount = self.amount || 1
        target = Character.named(self.target || enactor_name)
        if !target
          return CoD.system_emit t('cod.invalid_character', char: self.target), client
        elsif !target.is_approved?
          return CoD.system_emit t('cod.character_must_be_approved', name: target.name), client
        end

        curr_xp = CoD.get_rating(target.sheet, 'curr_xp').ceil(1)
        if !cmd.switch
          xp = CoD.get_rating(target.sheet, 'xp').ceil(1)
          return CoD.system_emit t('cod.current_xp', curr: curr_xp, total: xp), client, nil, :info
        elsif !['spend', 'award', 'beats'].include? cmd.switch
          return CoD.system_emit t('cod.invalid_switch', switch: cmd.switch), client
        end

        return CoD.sytem_emit t('cod.amount_cant_be_negative') if amount < 0
        action = nil
        case cmd.switch
        when 'spend'
          return CoD.system_emit t('cod.insufficient_xp'), client if amount > curr_xp
          CoD.spend_xp(enactor, target.sheet, amount, self.msg)
          action = 'spends'
        when 'award'
          CoD.award_xp(enactor, target.sheet, amount.round(1), self.msg)
          action = 'awards'
        when 'beats'
          amount = amount * 0.2
          CoD.award_xp(enactor, target.sheet, amount.round(1), self.msg)
          action = 'awards'
        end

        msg = "#{enactor_name} #{action} #{amount.abs.round(1)} " +
          "XP#{target.name != enactor_name ? " #{action == 'awards' ? 'to' : 'for'} " +
          "#{target.name}" : ''}#{self.msg ? ": #{self.msg}" : '.'}"
        CoD.system_emit msg, client, nil, :info
        if enactor.id != target.id
          t_client = Global.client_monitor.find_client(target)
          CoD.system_emit(msg, t_client, nil, :info) if t_client
        end
      end
    end
  end
end
