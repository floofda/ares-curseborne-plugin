module AresMUSH
  module CoD
    class SceneCombatInfoHandler
      def handle(request)
        scene = Scene[request.args[:scene_id]]
        enactor = request.enactor

        error = Website.check_login(request)
        return error if error

        return { error: t('webportal.not_found') } if !scene
        return { error: t('scenes.access_not_allowed') } if !Scenes.can_read_scene? enactor, scene
        return { error: t('scenes.scene_already_completed') } if scene.completed

        combat = Combat.find(scene_id: scene.id).first
        return CoD.build_web_combat_data(combat) if combat
        {}
      end
    end
  end
end
