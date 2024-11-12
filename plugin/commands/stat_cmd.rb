module AresMUSH
  module CoD
    class StatCmd
      include CommandHandler

      attr_accessor :target, :stat, :value, :msg

      def parse_args
        args = cmd.parse_args(/(?<target>[^\/]+)\/(?<stat>[^\=]+)\=?(?<msg>.+)?/)
        self.target = trim_arg(args.target)
        split = trim_arg(args.stat).split(':')
        self.value = split.pop
        self.stat = split.join(':')
        self.value = 0 if cmd.switch == 'remove'
        self.msg = trim_arg(args.msg)
      end

      def required_args
        [ self.target, self.stat, self.value ]
      end

      def handle
        return CoD.system_emit(t('cod.permission_denied'), client) if !enactor.is_admin?
        return CoD.system_emit(t('cod.invalid_switch'), client) if !cmd.switch

        target = Character.named(self.target || enactor_name)
        if !target
          return CoD.system_emit t('cod.invalid_character', char: self.target), client
        elsif !target.is_approved?
          return CoD.system_emit t('cod.character_must_be_approved', name: target.name), client
        end

        name, spec = self.stat.split('.')
        type_name, name = name.split(':')

        if !name
          name = type_name
          type_name = nil
        end
        self.stat = "#{name}#{spec ? ".#{spec}" : ''}"

        category = CoD.get_stat_category(target.sheet, self.stat)
        return CoD.system_emit(t('cod.invalid_stat', stat: self.stat), client) if !category

        if category == 'Ability'
          type = CoD.get_ability_type(target.sheet.template, type_name)
          stat = CoD.get_stat(target.sheet, self.stat, category, type)
          stat = nil if stat && type && stat.type != type.dig('name')
          type = CoD.get_ability_type(target.sheet.template, stat.type) if stat
        else
          stat = CoD.get_stat(target.sheet, self.stat, category)
        end

        if stat
          mod_name = "#{CoD.get_field(stat, :name)}"
          if category == 'Merit' && !CoD.get_field(stat, :spec).nil?
            mod_name += ".#{CoD.get_field(stat, :spec)}"
          elsif category == 'Skill' && spec
            mod_name += ".#{CoD.get_skill_specialty(stat, spec) || spec}"
          elsif category == 'Ability' && type['spec_required'] && !CoD.get_field(stat, :spec).nil?
            mod_name += ".#{CoD.get_field(stat, :spec)}"
          end
        end

        if !stat
          stat = CoD.get_config_stat(target.sheet.template, name, type&.dig('name'))
          return CoD.system_emit(t('cod.x_not_on_sheet', stat: stat['name']), client) if stat && self.value == '0'
          stat.delete('has_spec') if type && !type['spec_required']
          mod_name = "#{stat['name']}#{stat['has_spec'] ? ".#{spec}" : ''}" if stat
        end

        return CoD.system_emit(t('cod.invalid_stat', stat: self.stat), client) if !stat
        if category == 'Ability'
          ability = CoD.abilities(target.sheet.template, type&.dig('config')).select { |a| a['name'] == name }.first
          category = "#{type&.dig('name') || ''}#{category}"

          if !spec && (type ? type['spec_required'] : CoD.get_field(ability, :has_spec))
            return CoD.system_emit t('cod.requires_more_info', field: CoD.get_field(ability, :name)), client
          end
        elsif !spec && CoD.get_field(stat, :has_spec)
          return CoD.system_emit t('cod.requires_more_info', field: CoD.get_field(stat, :name)), client
        end

        new_value = self.value.gsub(/^[+-]/, '')
        action = cmd.switch.to_sym
        actions = { set: 'set to', raise: 'raised by', lower: 'lowered by' }

        if [:raise, :lower].include?(action)
          if !CoD.is_numeric?(new_value)
            return CoD.system_emit t('cod.value_must_be_numeric', value: self.value), client
          end
          new_value = "#{:lower == action ? '-' : '+'}#{new_value}"
        end

        CoD.create_modification(enactor, target.sheet, "#{category}:#{mod_name}:#{new_value}", self.msg)
        CoD.run_modifications(target.sheet)
        CoD.build_derived_stats(target.sheet, true)

        msg = "#{mod_name} #{actions[action]} '#{new_value.gsub(/^[+-]/, '')}' on #{target.name}."
        CoD.system_emit msg, client, nil, :info
      end
    end
  end
end
