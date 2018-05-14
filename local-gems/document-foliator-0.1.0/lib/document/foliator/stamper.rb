require "prawn"
require "open-uri"
require "combine_pdf"
require "document/foliator/combine_pdf_service"
require "active_support/time"

module Document
  module Foliator

    class Stamper
      def self.stamp(pdf, stamp_url, date)
        date = Time.parse(date)
        if !(date.hour == 0 && date.min == 0 && date.sec == 0)
          date = date + (ActiveSupport::TimeZone["America/Santiago"].parse(date.to_s).utc_offset / 3600).hours
        end
        text_size = 10
        stamp_width = 110
        stamp_date_left_padding = 31
        stamp_date_top_padding = 30
        stamp_bottom_padding = 25
        top_right = [0, 0]
        
        number_of_pages = pdf.pages.count

        width, height = CombinePdfService.get_page_dimensions(pdf.pages[0])
        
        stamp_pdf = Prawn::Document.new(page_size: [width, height])

        stamp_pdf.font_families.update("Roboto" => {
          normal: ROOT_DIR.join("assets/fonts/Roboto-Regular.ttf"),
          bold: ROOT_DIR.join("assets/fonts/Roboto-Bold.ttf"),
          italic: ROOT_DIR.join("assets/fonts/Roboto-Italic.ttf"),
          bold_italic: ROOT_DIR.join("assets/fonts/Roboto-BoldItalic.ttf")
        })
        stamp_pdf.font("Roboto", :style => :normal)

        top_right = stamp_pdf.bounds.top_right
        top_left = stamp_pdf.bounds.top_left
        top_left_middle_center = stamp_pdf.bounds.top_left
        top_center = stamp_pdf.bounds.top_left
        top_center[0] += (top_left[0] + top_right[0])/2
        top_center[1] += stamp_bottom_padding
        top_left_middle_center[0] = (top_left[0] + top_center[0])/2
        stamp_image = open(stamp_url)
        stamp_pdf.image stamp_image, :at => [top_center[0] - stamp_width/2, top_center[1]], :width => stamp_width
        stamp_pdf.draw_text date.strftime("%d-%m-%Y") , :at => [top_center[0] - stamp_width/2 + stamp_date_left_padding, top_center[1] - text_size - stamp_date_top_padding], :size => text_size

        to_combine_stamp_pdf = CombinePDF.parse(stamp_pdf.render)
        pdf.pages(false)[0] << to_combine_stamp_pdf.pages(false)[0]

        result = pdf
        # TCT: Freeing space
        pdf = nil
        to_combine_stamp_pdf = nil
        stamp_pdf = nil
        return result
      end
    end
  end
end
