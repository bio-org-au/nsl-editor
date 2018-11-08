# frozen_string_literal: true

# Name scopes
module NameEnterable
  extend ActiveSupport::Concern
  included do
  end

  def status_options
    NameStatus.options_for_category(category_for_edit)
  end

  def takes_name_element?
    category_for_edit.takes_name_element?
  end

  def takes_rank?
    category_for_edit.takes_rank?
  end

  def takes_authors?
    category_for_edit.takes_authors?
  end

  def takes_author_only?
    category_for_edit.takes_author_only?
  end

  def takes_verbatim_rank?
    category_for_edit.takes_verbatim_rank?
  end

  def requires_name_element?
    category_for_edit.requires_name_element?
  end

  def needs_top_buttons?
    category_for_edit.needs_top_buttons?
  end

  def requires_higher_ranked_parent?
    category_for_edit.requires_higher_ranked_parent?
  end
  
  def name_type_must_match_category
    return if NameType.option_ids_for_category(category_for_edit).include?(name_type_id)
    errors.add(:name_type_id,
               "Wrong name type for category! Category: #{category_for_edit} vs
               name type: #{name_type.name}.")
  end

  def category_name_for_edit
    change_category_name_to.present? ? change_category_name_to : name_type.name_category.name
  end

  def category_for_edit
    NameCategory.find_by_name(category_name_for_edit)
  end
end
