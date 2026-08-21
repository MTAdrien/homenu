class Chat < ApplicationRecord
  DEFAULT_TITLE = "Untitled"

  TITLE_PROMPT = <<~PROMPT
    Use the title of the recipe suggested in the assistant response as the chat title.
    Return only the recipe title.
  PROMPT

  belongs_to :household
  belongs_to :user, optional: true

  has_many :messages, dependent: :destroy

  def generate_title_from_first_message
    return unless name == DEFAULT_TITLE

    first_user_message = messages.where(role: "user").order(:created_at).first
    return if first_user_message.nil?

    response = RubyLLM.chat
      .with_instructions(TITLE_PROMPT)
      .ask(first_user_message.content)

    update(name: response.content)
  end
end
