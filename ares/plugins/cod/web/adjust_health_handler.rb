module AresMUSH
  module CoD
    class AdjustHealthHandler
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

        data = request.args
        res, error = CoD.build_adjust_health_emit({
          enactor: enactor,
          char: target&.name || enactor.name,
          value: data[:value].to_i,
          type: ['agg', 'lethal', 'bashing'][[data[:agg], data[:lethal], data[:bashing]].index('true') || 2]
        })

        return { c_error: error } if error
        CoD.emit_message res, nil, scene.room, true
        {}
      end
    end
  end
end
