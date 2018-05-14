require "document/foliator/version"
require "document/foliator/combine_pdf_service"
require "document/foliator/number_to_human"
require "document/foliator/logger"
require "document/foliator/stamper"
require "prawn"
require "combine_pdf"
require "open-uri"

module Document
  module Foliator
    module_function

    ROOT_DIR = Pathname.new(__FILE__).join("../../..")

    def foliate(pdf, start_folio, just_folios, pixels_to_left, double_sided, every_other_page)
      logger.info "Foliating PDF"
      text_size = 10
      start_folio = start_folio.to_i
      top_right = [0, 0]
      number_of_pages = pdf.pages.count

      if every_other_page
        end_folio = ((start_folio + number_of_pages - 1) / 2).to_i
      else
        end_folio = start_folio + number_of_pages - 1
      end

      width, height = CombinePdfService.get_page_dimensions(pdf.pages[0])

      folios_pdf = Prawn::Document.new(page_size: [width, height])

      folios_pdf.font_families.update("Roboto" => {
        normal: ROOT_DIR.join("assets/fonts/Roboto-Regular.ttf"),
        bold: ROOT_DIR.join("assets/fonts/Roboto-Bold.ttf"),
        italic: ROOT_DIR.join("assets/fonts/Roboto-Italic.ttf"),
        bold_italic: ROOT_DIR.join("assets/fonts/Roboto-BoldItalic.ttf")
      })
      folios_pdf.font("Roboto", :style => :normal)

      step = true

      folio = start_folio
      (1..number_of_pages).each do |i|
        top_right = folios_pdf.bounds.top_right
        if !every_other_page || (every_other_page && step)
          if double_sided
            if step
              page_number_text = "Fojas #{folio + 1}"
              number_print = folio + 1
            else
              page_number_text = "Fojas #{folio - 1}"
              number_print = folio - 1
            end
          else
            page_number_text = "Fojas #{folio}"
            number_print = folio
          end

          text_width = folios_pdf.width_of(page_number_text, size: text_size)
          folio_position = [top_right[0] - text_width - pixels_to_left.to_i, top_right[1]]
          folios_pdf.draw_text page_number_text, :at => folio_position, :size => text_size
          human_number = NumberToHuman.number_to_human(number_print).to_s
          folios_pdf.draw_text human_number, :at => [top_right[0] - folios_pdf.width_of(human_number, size: text_size) - pixels_to_left.to_i, top_right[1] - text_size], :size => text_size
          folio += 1
        end

        if i < number_of_pages
          width, height = CombinePdfService.get_page_dimensions(pdf.pages[i])
          folios_pdf.start_new_page(:size => [width, height])
          step = !step
        end
      end

      pdf_folios = CombinePDF.parse folios_pdf.render
      result = pdf_folios

      if !just_folios
        pdf.pages(false).each_with_index do |page, index|
          new_page = pdf_folios.pages(false)[index]
          page << new_page
        end
        result = pdf
      end
      # TCT: Freeing space
      pdf = nil
      pdf_folios = nil
      folios_pdf = nil

      logger.info("PDF foliated successfully. Foliated pages: #{number_of_pages} pages")
      return result
    end

    def foliate_from_url(file_url, start_folio, just_folios, pixels_to_left, double_sided, every_other_page, stamp_url=nil, issue_date=nil)
      begin
        logger.info "Getting file from: #{file_url}"
        file = open file_url
        logger.info "Parsing file to PDF"
        pdf = CombinePDF.parse file.read
        foliated_pdf = Document::Foliator.foliate(pdf, start_folio, just_folios, pixels_to_left, double_sided, every_other_page)
        if stamp_url && issue_date
          logger.info "Including stamp image from: #{stamp_url}"
          foliated_pdf = Stamper.stamp(foliated_pdf, stamp_url, issue_date)
        end
        return foliated_pdf
      rescue => err
        logger.fatal "Error while trying to foliate file from: #{file_url}"
        logger.fatal err
        return nil
      end
    end
  end
end
