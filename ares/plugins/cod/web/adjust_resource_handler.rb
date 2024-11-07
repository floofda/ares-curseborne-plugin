module AresMUSH
  module CoD
    class AdjustResourceHandler
      def handle(request)
        scene = Scene[request.args[:id]]
        target = Character.named(request.args[:char]) || Npc.named(request.args[:char])
        enactor = request.enactor
        data = request.args
        amount = data[:value].to_i

        error = Website.check_login(request)
        return error if error

        return { c_error: t('webportal.not_found') } if !scene
        return { c_error: t('scenes.access_not_allowed') } if !Scenes.can_read_scene? enactor, scene
        return { c_error: t('scenes.scene_already_completed') } if scene.completed
        if !CoD.is_st?(enactor) && (CoD.is_npc?(target) && target.creator_id != enactor.id)
          return { c_error: t('cod.no_permission_to_change_x', name: target.name) }
        end

        if CoD.is_npc? target
          config = { resource: target.sheet[:resource_name], morality: target.sheet[:morality_name] }.with_indifferent_access
        else
          config = CoD.get_template_config(target.sheet.template)
        end

        map = [
          { field: 'wp', name: 'Willpower' },
          { field: 'resource', name: config&.dig('resource') || :resource },
          { field: 'morality', name: config&.dig('morality') || :morality }
        ]

        type = map.select { |t| t[:name]&.start_with? (data[:type] || 'x') }.first
        return { c_error: t('cod.invalid_switch', switch: data[:type]) } if !type

        stat = CoD.get_stat(target.sheet, type[:name])
        curr = CoD.get_rating(target.sheet, "curr_#{type[:field]}")
        if !(curr + amount).between?(0, stat[:value])
          return { c_error: t('cod.invalid_points') }
        end

        CoD.set_stat(target.sheet, 'field', "curr_#{type[:field]}", amount)
        action = amount <= 0 ? (type[:field] == 'morality' ? 'loses' : 'spent') : 'regains'
        msg = "#{target.name} #{action} #{amount.abs} #{type[:name]}"
        CoD.system_emit msg, nil, scene.room, :info
        {}
      end
    end
  end
end
