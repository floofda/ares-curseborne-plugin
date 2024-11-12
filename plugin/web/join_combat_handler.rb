module AresMUSH
  module CoD
    class JoinCombatHandler
      def handle(request)
        scene = Scene[request.args[:scene_id]]
        combat = Combat[request.args[:combat_id]]
        target = Character.named(request.args[:target]) || request.enactor

        error = Website.check_login(request)
        return error if error

        return { error: t('webportal.not_found') } if !scene
        return { error: t('scenes.access_not_allowed') } if !Scenes.can_read_scene? request.enactor, scene
        return { error: t('scenes.scene_already_completed') } if scene.completed
        return { error: t('cod.combat_not_found') } if !combat

        CoD.add_combatant combat, target
        CoD.system_emit t('cod.x_has_joined_combat', name: target.name), nil, scene.room, :info
        return CoD.build_web_combat_data(combat)
      end
    end
  end
end
