module AresMUSH
  module CoD
    class SheetTemplate < ErbTemplateRenderer

      attr_accessor :char, :client, :section

      def initialize(char, client, section = nil)
        @char = char
        @client = client
        @section = section
        super File.dirname(__FILE__) + '/sheet.erb'
      end

      def approval_status
        @char.is_approved? ? @char.sheet.concept : Chargen.approval_status(@char)
      end

      def xp
        "#{@char.sheet.curr_xp.round(1)} / #{@char.sheet.xp.round(1)}"
      end

      def base
        sheet = @char.sheet
        classifications = []
        if sheet.template_config['classifications']
          sheet.template_config['classifications'].each { |c| classifications.push ({ name: c['name'], value: c['value']})}
          classifications << { name: '', value: '' } if classifications.size == 2
        end

        fields = []
        fields << { name: sheet.template_config['power'], value: CoD.get_rating(sheet, 'power') } if sheet.template_config['power']
        fields << { name: 'Willpower', value: "#{sheet.curr_wp}/#{CoD.get_rating(sheet, 'willpower')}" }

        set = sheet.template_config.dig('anchors')&.map { |a| a.transform_keys(&:to_sym) }
        set = [] if !set
        set << {
          name: sheet.template_config['morality'],
          value: sheet.curr_morality != sheet.morality ? "#{sheet.curr_morality}/#{sheet.morality}" : sheet.morality
        }

        if sheet.template_config['resource']
          set << {
            name: sheet.template_config['resource'],
            value: "#{sheet.curr_resource}/#{sheet.resource}"
          }
        end

        list = []
        info = (classifications + set + fields).flatten
        if info.size > 5
          info = info.each_slice(3).to_a
          order = info.shift&.zip(info.shift || [], info.shift || [])&.flatten&.compact
        else
          order = info
        end
        order&.each_with_index { |a, i| list << format_three_col(a, i, false) }
        list
      end

      def attrs
        list = []
        return list if @char.sheet.cod_attributes.size == 0
        attrs = @char.sheet.cod_attributes.each_slice(3).to_a
        order = attrs.shift&.zip(attrs.shift, attrs.shift)&.flatten&.compact
        order&.each_with_index { |a, i| list << format_three_col(a, i) }
        list
      end

      def skills
        list = []
        return list if @char.sheet.skills.size == 0
        skills = @char.sheet.skills.group_by { |s| s.category }.values_at(*['mental', 'physical', 'social']).flatten.each_slice(8).to_a
        order = skills.shift&.zip(skills.shift, skills.shift)&.flatten&.compact
        order&.each_with_index { |a, i| list << format_three_col(a, i) }
        list
      end

      def specialties
        skills = @char.sheet.skills.select { |s| !s.specialties.empty? }
        skills.each_with_index.map { |s, i|
          format_specialties({skill: s.name, specialties: s.specialties.join(', ')}, i)
        }
      end

      def merits
        return [] if @char.sheet.merits.size == 0
        @char.sheet.merits.each_with_index.map { |m, i|
          linebreak = (i % 2) == 0 ? "%r" : ""
          name = (m.spec && !m.spec.empty?) ? "#{m.name} %x8(%xn#{m.spec}%x8)%xn"  : m.name
          "#{linebreak} #{left(name, 36)}#{right(m.rating, 1)} "
        }
      end

      def abilities
        config = @char.sheet.template_config['abilities']
        return if !config
        config.map { |t|
          {
            title: t['plural'],
            abilities: @char.sheet.abilities_by_type(t['name']).each_with_index.map { |a, i|
              linebreak = (i % 2) == 0 ? "%r" : ""
              name = a.spec ? "#{a.name} %x8(%xn#{a.spec}%x8)%xn"  : a.name
              "#{linebreak} #{left(name, 36)}#{right(a.rating, 1)} "
            }
          }
        }
      end

      def format_three_col(s, i, dots = true)
        name = s.is_a?(Hash) ? s[:name] : s.name
        name_len = name&.length || 0
        value = s.is_a?(Hash) ? s[:value] : s.rating
        space = dots ? ''.rjust(22 - name.length, '.') : ' ' * ([23 - name_len - "#{value}".length, 1].max)
        linebreak = (i % 3) == 0 ? '%r' : ''
        "#{linebreak}%x7 #{name}%xn%x8#{space}%xn%x7 #{"#{value}"[0..(21 - name_len)]} %xn"
      end

      def format_specialties(a, i)
        linebreak = (i % 2) == 0 ? '%r' : ''
        out = "#{a[:skill]} %x8(%xn#{a[:specialties]}%x8)%xn"
        "#{linebreak} #{left(out, 38)}"
      end

      def section_line(left, right = nil)
        @client.screen_reader ? left : CoD.header_line(left, right)
      end

      def footer_line(left = nil)
        @client.screen_reader ? left : CoD.footer_line(left)
      end

    end
  end
end
