module HasIdentifier
  extend ActiveSupport::Concern

  included do
    class_attribute :identifier_prefix

    validates(:identifier, presence: true)

    after_initialize{
      def r(i); SecureRandom.send(:choose, [*?1..?9, *?A..?H, *?J..?N, *?P..?Z], i); end
      self.identifier ||= "#{identifier_prefix}#{r(5)}-#{r(5)}-#{r(6)}"
    }
  end
end


ActiveRecord::ConnectionAdapters::TableDefinition.class_eval do
  # usage of t.identifier inside migrations
  def identifier
    column(:identifier, :string, length: 19, null: false, index: true, unique: true)
  end
end
