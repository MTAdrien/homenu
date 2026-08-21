class Chat < ApplicationRecord
  DEFAULT_TITLE = "Untitled"

#   TITLE_PROMPT = <<~PROMPT
#     Use the title of the recipe suggested in the assistant response as the chat title.
#     Return only the recipe title.
#   PROMPT

  belongs_to :household
  belongs_to :user, optional: true

  has_many :messages, dependent: :destroy

  def generate_title_from_recipe(content)
    return unless name == DEFAULT_TITLE

#     first_user_message = messages.where(role: "user").order(:created_at).first
#     return if first_user_message.nil?

#     response = RubyLLM.chat
#       .with_instructions(TITLE_PROMPT)
#       .ask(first_user_message.content)
#
    title_line = content.lines.find { |line| line.start_with?("## ") }
    return if title_line.nil?

    recipe_title = title_line.delete_prefix("## ").strip

    update(name: recipe_title)
  end
end
