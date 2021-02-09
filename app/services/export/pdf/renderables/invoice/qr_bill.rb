# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      module Invoice
        class QrBill < Renderable
          include Translatable
          HEIGHT = 297
          WIDTH = 495 + 100
          PADDING = 15

          attr_reader :qr_bill

          def initialize(qr_bill)
            super()
            @qr_bill = qr_bill
          end

          def render
            start_new_page if cursor < 240
            default_leading 0
            bounding_box([-60, HEIGHT - 50], width: WIDTH, height: HEIGHT) do
              render_receipt_part
              render_qrcode_part
              render_debitor_part
              render_cutting_lines
            end
          end

          private

          def render_receipt_part
            bounding_box([bounds.left + PADDING, bounds.top], width: 160, height: HEIGHT) do
              move_down PADDING
              text t('receipt_title'), size: 11, style: :bold
              move_down 9
              render_creditor
              move_down 9
              render_ref
              render_amount(bounds.left, 101)
            end
          end

          def render_amount(left, bottom)
            bounding_box([left, bottom], width: 40) do
              text t('currency'), size: 7, style: :bold
              move_down 3
              text qr_bill.currency
            end
            bounding_box([left + 50, bottom], width: 100) do
              text t('amount'), size: 7, style: :bold
              move_down 3
              text qr_bill.formatted_amount
            end
          end

          def render_creditor
            text t('creditor_account'), size: 7, style: :bold
            text qr_bill.creditor_account
            text qr_bill.creditor_address_lines.join("\n")
            move_down 2
          end

          def render_debitor
            text t('payable_by'), size: 7, style: :bold
            text qr_bill.debitor_address_lines.join("\n")
            move_down 2
          end

          def render_ref
            text t('ref'), size: 7, style: :bold
            text qr_bill.formatted_ref
          end

          def render_qrcode_part
            bounding_box([bounds.left + 190, bounds.top], width: 130, height: HEIGHT) do
              move_down PADDING
              text t('payment_part_title'), size: 11, style: :bold
              move_down 17
              render_qrcode
              render_amount(bounds.left, 101)
            end
          end

          def render_debitor_part
            bounding_box([bounds.left + 335, bounds.top], width: 180, height: HEIGHT) do
              move_down PADDING
              render_creditor
              move_down 9
              render_ref
              move_down 9
              render_debitor
            end
          end

          def render_qrcode
            qrcode_image = @qr_bill.qrcode.as_png(bit_depth: 1, border_modules: 0).to_s

            image StringIO.open(qrcode_image), fit: [bounds.width, bounds.width]
            image Rails.root.join('app/webpack/images/ch_cross.png'), fit: [20, 20], at: [55, cursor + 56 + 20]
          end

          def render_cutting_lines
            dash [4, 2]
            line_width 0.5
            stroke_horizontal_line(bounds.left, bounds.right, at: HEIGHT)
            stroke_vertical_line(bounds.top, bounds.bottom, at: 175)
          end
        end
      end
    end
  end
end
