module MembersHelper
  AVATAR_COLORS = %w[#7a9a7a #b8a888 #6b8e6b #a8b89a #8ca88c].freeze

  def avatar_color(name)
    AVATAR_COLORS[name.to_s.sum % AVATAR_COLORS.size]
  end
end
