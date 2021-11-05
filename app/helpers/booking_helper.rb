# frozen_string_literal: true

module BookingHelper
  def homes_for_select
    current_organisation.homes.map { |home| [home.to_s, home.to_param] }
  end

  def selector_votes(usage)
    return unless usage.tarif_selector_votes.any?

    tag.ul(class: 'list-unstyled m-0') do
      safe_join(usage.tarif_selector_votes.map do |selector, vote|
        tag.li do
          selector_vote(selector, vote)
        end
      end)
    end
  end

  def selector_vote(selector, vote)
    # rubocop:disable Style/StringConcatenation
    (vote ? tag.span(class: 'fa fa-check') : tag.span(class: 'fa fa-times')) +
      link_to(edit_manage_home_tarif_path(selector.home, selector.tarif), class: 'me-2') do
        selector.model_name.human
      end +
      ': ' +
      selector.distinction
    # rubocop:enable Style/StringConcatenation
  end
end
