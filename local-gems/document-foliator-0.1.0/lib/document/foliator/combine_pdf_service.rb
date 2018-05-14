module Document
  module Foliator

    class CombinePdfService
      def self.get_page_dimensions page
        bbox = page.page_size
        width  = bbox[2] - bbox[0]
        height = bbox[3] - bbox[1]
        [width, height]
      end
    end
  end
end
