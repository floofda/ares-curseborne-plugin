module AresMUSH
  module CoD
    class AwardBeatsJobHandler
      def handle(request)
        job = Job[request.args['id']]
        char = Character.named(request.args['char'])
        enactor = request.enactor
        beats = request.args['beats']
        message = request.args['message']

        error = Website.check_login(request)
        return error if error

        return { c_error: t('cod.missing_field', field: 'Beats') } if beats.empty?
        return { c_error: t('cod.missing_field', field: 'Message') } if message.empty?
        return { c_error: t('cod.permission_denied') } if !CoD.is_st?(enactor)
        return { c_error: t('webportal.not_found') } if !job
        return { c_error: t('jobs.cant_view_job') } if !Jobs.can_access_job? enactor, job, true
        return { c_error: t('cod.invalid_character', char: request.args[:char]) } if !char
        return { c_error: t('cod.character_must_be_approved', name: char.name) } if !char.is_approved?

        beats = beats.to_i
        CoD.award_xp enactor, char.sheet, beats * 0.2, message
        Jobs.comment job, enactor, t('cod.beats_awarded_for', beats: beats, name: char.name, message: message), false

        return { c_error: error } if error
        {}
      end
    end
  end
end
