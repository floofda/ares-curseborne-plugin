module AresMUSH
  module CoD
    class ResourceCmd
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

      def handle
        if self.target != enactor_name && !CoD.is_st?(enactor)
          return CoD.system_emit t('cod.permission_denied'), client
        end

        amount = self.amount || 1
        target = Character.named(self.target || enactor_name)

        if (cmd.root == 'spend' || cmd.root == 'lose')
          amount = -amount
          action = cmd.root == 'spend' ? 'spent' : 'loses'
        else
          action = 'regains'
        end

        if !target
          return CoD.system_emit t('cod.invalid_character', char: self.target), client
        elsif !target.is_approved?
          return CoD.system_emit t('cod.character_must_be_approved', name: target.name), client
        end

        config = CoD.get_template_config(target.sheet.template)
        map = [
          { field: 'wp', switch: 'wp', name: 'Willpower' },
          { field: 'resource', switch: config['resource'], name: config['resource'] },
          { field: 'morality', switch: config['morality'], name: config['morality'] }
        ]

        type = map.select { |t| t[:switch]&.downcase&.start_with? (cmd.switch || 'x') }.first
        return CoD.system_emit(t('cod.invalid_switch', switch: cmd.switch), client) if !type

        stat = CoD.get_stat(target.sheet, type[:name])
        curr = CoD.get_rating(target.sheet, "curr_#{type[:field]}")

        if !(curr + amount).between?(0, stat[:value])
          return CoD.system_emit(t('cod.invalid_points'), client)
        end

        CoD.set_stat(target.sheet, 'field', "curr_#{type[:field]}", amount)

        msg = "#{enactor_name} #{action} #{amount.abs} #{type[:name]}#{target.name != enactor_name ? " for #{target.name}" : ''}."
        CoD.system_emit msg, client, enactor_room, :info
      end
    end
  end
end
