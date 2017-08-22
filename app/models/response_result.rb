class ResponseResult
	include ActiveModel::Model
	include ActiveModel::Serialization
	attr_accessor :isSuccess, :message, :value

	def initialize(attributes={})
		super
		@isSuccess ||= true
	end

	def attributes
		{
				'isSuccess' => nil,
				'message' => nil,
				'value' => nil,
		}
	end
end