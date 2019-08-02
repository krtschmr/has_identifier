module HasIdentifier
  extend ActiveSupport::Concern

  included do
    class_attribute :identifier_prefix
    after_initialize :generate_identifier
    validates :identifier, presence: true, uniqueness: { allow_blank: false,case_sensitive: false}, on: :create
  end

  ALPHABET = [*?1..?9, *?A..?H, *?J..?N, *?P..?Z]


  def short_identifier
    identifier.split("-").first
  end

  def gen_id_char(n)
    SecureRandom.send(:choose, ALPHABET, n)
  end

  def generate_identifier
    self.identifier ||= "#{identifier_prefix}#{gen_id_char(5)}-#{gen_id_char(5)}-#{gen_id_char(6)}"
  end
end


ActiveRecord::ConnectionAdapters::TableDefinition.class_eval do
  # usage of t.identifier inside migrations
  def identifier
    column(:identifier, :string, length: 19, null: false, index: true, unique: true)
  end
end
