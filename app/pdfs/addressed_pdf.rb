require 'prawn'

class AddressedPdf < BasePdf
  part :addresses do |_doc|
    bounding_box [0, 670], width: 200, height: 170 do
      default_leading 3
      text 'Vermieter', size: 13, style: :bold
      move_down 5
      text 'vertreten durch:', size: 9
      text "Verein Pfadiheime St. Georg\nHeimverwaltung\nChristian Morger\nGeeringstr. 44\n8049 Zürich", size: 10
      text "\nTel: 079 262 25 48\nEmail: info@pfadi-heime.ch", size: 9
    end

    bounding_box [300, 670], width: 200, height: 170 do
      default_leading 4
      text 'Mieter', size: 13, style: :bold
      move_down 5
      text @booking.ref, size: 9
      text @booking.organisation, size: 9
      text @booking.customer.address_lines.join("\n"), size: 11
    end
  end

  part :title do |_doc|
    move_down 20
    text @title, size: 20, style: :bold
  end
end
