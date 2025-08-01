module AresMUSH
  module CoD
    class CombatStartHandler
      def handle(request)
        scene = Scene[request.args['scene_id']]
        enactor = request.enactor

        error = Website.check_login(request)
        return error if error

        return { error: t('webportal.not_found') } if !scene
        return { error: t('scenes.access_not_allowed') } if !Scenes.can_read_scene? enactor, scene
        return { error: t('scenes.scene_already_completed') } if scene.completed

        combat = Combat.find(scene_id: scene.id).first
        return { error: t('cod.combat_tracker_already_exists_for_scene') } if combat

        combat = Combat.create(scene_id: scene.id, owner_id: enactor.id)
        CoD.system_emit t('cod.combat_tracker_started'), nil, scene.room, :info
        CoD.build_web_combat_data combat
      end
    end
  end
end
