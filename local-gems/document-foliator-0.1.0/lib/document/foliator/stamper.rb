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
        stamp_date = date.strftime("%d-%m-%Y")
        text_size = 10
        stamp_width = 110
        stamp_date_left_padding = 31
        stamp_date_top_padding = 30
        stamp_bottom_padding = 25
        top_right = [0, 0]
        page = pdf.pages[0]
        page_rotation = page[:Rotate] || 0

        width, height = CombinePdfService.get_page_dimensions(page)
        stamp_pdf = Prawn::Document.new(page_size: [width, height])

        stamp_pdf.font_families.update("Roboto" => {
          normal: ROOT_DIR.join("assets/fonts/Roboto-Regular.ttf"),
          bold: ROOT_DIR.join("assets/fonts/Roboto-Bold.ttf"),
          italic: ROOT_DIR.join("assets/fonts/Roboto-Italic.ttf"),
          bold_italic: ROOT_DIR.join("assets/fonts/Roboto-BoldItalic.ttf")
        })
        stamp_pdf.font("Roboto", :style => :normal)

        bounds = stamp_pdf.bounds

        if page_rotation == 90
          top_left = bounds.bottom_left
          top_right = bounds.top_left
          top_center = [top_left[0], top_right[1] / 2]
          stamp_position = [top_center[0] - stamp_width/2, top_center[1] + stamp_bottom_padding]
          date_position = [top_center[0] + stamp_date_left_padding/2, top_center[1] + stamp_date.length/2 - stamp_date_top_padding]
        elsif page_rotation == 180
          top_left = bounds.bottom_right
          top_right = bounds.bottom_left
          top_center = [top_left[0] / 2 , top_left[1]]
          stamp_position = [top_center[0] - stamp_width/2, top_center[1] + stamp_bottom_padding]
          date_position = [top_center[0] + stamp_width/2 - stamp_date_left_padding, top_center[1] + stamp_date_top_padding/2]
        elsif page_rotation == 270
          top_left = bounds.top_right
          top_right = bounds.bottom_right
          top_center = [top_left[0], top_left[1] / 2]
          stamp_position = [top_center[0] - stamp_width / 2, top_center[1] + stamp_bottom_padding]
          date_position = [top_center[0] - stamp_date_left_padding/2, top_center[1] - stamp_date.length/2 + stamp_date_top_padding]
        else
          top_left = bounds.top_left
          top_right = bounds.top_right
          top_center = top_left
          top_center[0] += (top_left[0] + top_right[0])/2
          top_center[1] += stamp_bottom_padding
          stamp_position = [top_center[0] - stamp_width/2, top_center[1]]
          date_position = [top_center[0] - stamp_width/2 + stamp_date_left_padding, top_center[1] - text_size - stamp_date_top_padding]
        end

        stamp_image = open(stamp_url)
        stamp_pdf.rotate(page_rotation, origin: top_center) do
          stamp_pdf.image stamp_image, :at => stamp_position, :width => stamp_width
        end
        stamp_pdf.draw_text date.strftime("%d-%m-%Y") , at: date_position, size: text_size, rotate: page_rotation

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
