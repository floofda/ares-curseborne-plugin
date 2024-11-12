module AresMUSH
  module CoD
    class BuildWebChargenInfo

      def build(char)
        template = char.sheet.template

        build = {
          attributes: CoD.attributes,
          skills: CoD.skills,
          merits: CoD.merits(template),
          template_info: CoD.get_template_config(template)
        }
        if build[:template_info]['abilities']
          build[:template_info]['abilities'].each { |a| build[a['key']] = CoD.abilities(template, a['config']) }
        end
        build
      end

    end
  end
end
