module AresMUSH
  module CoD
    class SetupTemplateHandler
      def handle(request)
        char = Character[request.args['id']]
        template = request.args[:template]

        error = Website.check_login(request)
        return error if error

        allowed_templates = Global.read_config('cod', 'chargen')['allowed_templates']

        if !char
          return { error: 'Invalid character' }
        elsif template.nil? || !Global.read_config('cod', 'chargen')['allowed_templates'].include?(template)
          return { error: 'Invalid template' }
        else
          char.sheet.update(template: template, cg_sheet: { template: template })
          groups = char.groups
          groups[:template] = template
          char.update(groups: groups)

          allowed_templates.each { |t|
            role = Role.find_one_by_name(CoD.to_key(t))
            return { error: "Invalide Role: #{t}" } if !role
            char.roles.delete(role) if char.has_role?(CoD.to_key(t))
          }
          role = Role.find_one_by_name(CoD.to_key(template))
          char.roles.add role
        end
        {
          name: char.id,
          template: char.sheet.template
        }
      end
    end
  end
end
