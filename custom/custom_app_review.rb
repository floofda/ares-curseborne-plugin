module AresMUSH
  module Chargen

    def self.custom_app_review(char)
      review = CoD.app_review(char)
      if review[:ok]
        CoD.cg_to_sheet(char)
      end
      "#{review[:sheet_errors]}%r%r#{review[:template_errors]}"
    end

  end
end