module PrecinctsHelper
  
  # ========================
  # = SETS FONT TO DEFAULT =
  # ========================
  def default_font(pdf)
    pdf.font @ballot_config[:ballot_column_headers_text_font], 
      :size => @ballot_config[:ballot_column_headers_text_size],  
      :style => @ballot_config[:ballot_column_headers_text_style]
  end
end
