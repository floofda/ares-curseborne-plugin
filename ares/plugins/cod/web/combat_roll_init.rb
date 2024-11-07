module AresMUSH
  module CoD
    class CombatRollInitHandler
      def handle(request)
        scene = Scene[request.args[:scene_id]]
        combat = Combat[request.args[:combat_id]]
        modifier = (request.args[:modifier] || 0).to_i
        enactor = request.enactor

        error = Website.check_login(request)
        return error if error

        return { error: t('webportal.not_found') } if !scene
        return { error: t('scenes.access_not_allowed') } if !Scenes.can_read_scene? enactor, scene
        return { error: t('scenes.scene_already_completed') } if scene.completed
        return { error: t('cod.combat_not_found') } if !combat

        mod_str = "#{modifier >= 0 ? '+' : '-'}#{modifier.abs}"
        if combat.init_list.member?(enactor.name) && combat.init_list[enactor.name] != 0
          CoD.set_init combat, enactor, [combat.init_list[enactor.name] + modifier, 1].max
          CoD.system_emit t('cod.initiative_modified', target: enactor.name, value: mod_str), nil, scene.room, :info
        else
          init = CoD.get_rating(enactor.sheet, 'initiative') + CoD.roll(1, 11)[:dice].first + modifier
          CoD.set_init(Combat[combat.id], enactor, init)
          bonus = modifier != 0 ? " (#{mod_str})" : ''
          CoD.system_emit t('cod.initiative_roll', target: enactor.name, value: init, bonus: bonus), nil, scene.room, :info
        end

        CoD.build_web_combat_data(combat)
      end
    end
  end
end
