module HasIdentifier
  extend ActiveSupport::Concern

  included do
    class_attribute :identifier_prefix
    after_initialize :generate_identifier
    validates :identifier, presence: true, uniqueness: { allow_blank: false, case_sensitive: false}, on: :create

    def self.find(*args)
      # if the argument is a string but it's not a string with just numbers
      if args.first.is_a?(String) && args.first.to_i == 0
        find_by!(identifier: args)
      else
        super
      end
    end

  end

  ALPHABET = [*?1..?9, *?A..?H, *?J..?N, *?P..?Z]



  def short_identifier
    identifier.split("-").first
  end

  def gen_id_char(n)
    SecureRandom.send(:choose, ALPHABET, n)
  end

  def generate_identifier
    self.identifier ||= "#{identifier_prefix}#{gen_id_char(5)}-#{gen_id_char(5)}-#{gen_id_char(6)}" if respond_to?(:identifier)
  end
end


ActiveRecord::ConnectionAdapters::TableDefinition.class_eval do
  # usage of t.identifier inside migrations
  def identifier
    column(:identifier, :string, length: 19, null: false, index: true, unique: true)
  end
end


ActiveRecord::Associations::CollectionAssociation.class_eval do
  def find(*args)
    if args.first.is_a?(String) && args.first.to_i == 0
      scope.find_by!(identifier: args)
    else
      super
    end
  end
end
