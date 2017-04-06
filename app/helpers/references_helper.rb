# frozen_string_literal: true

# Reference-specific helpers
module ReferencesHelper
  def display_pages(pages = "")
    if pages.blank?
      ""
    elsif pages =~ /null - null/
      ""
    else
      " : #{pages}"
    end
  end

  # Method is the end result of avoiding an embedded space
  # appearing before this optional comma.
  def optional_name_status_comma(search_result)
    return unless search_result.name
                               .name_status
                               .show_name_for_instance_display_within_reference?
    ","
  end
end
