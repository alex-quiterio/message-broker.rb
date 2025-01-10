# frozen_string_literal: true

module MessageBroker
  module Generators
    class ProducerGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      argument :resource_name,
               type: :string,
               description: "Resource or a category of topic, 'order_requests', 'users'"

      argument :event_name,
               type: :string,
               description: "Event name, e.g. 'created', 'updated'"

      class_option :namespace, type: :string, default: nil,
                               desc: "Namespace, e.g. 'order_requests', 'accounts'"

      def copy_producer
        empty_directory producer_dir
        template 'producer.rb.erb', File.join(producer_dir, file_name)
      end

      private

      def file_name
        "#{event_name}_job.rb"
      end

      def producer_dir
        namespace = options[:namespace] || ''
        File.join('app/jobs/producers', namespace, resource_name)
      end

      def producer_class_name
        event_name.camelcase + 'Job'
      end

      def producer_module_name
        [options[:namespace], resource_name].compact.map(&:capitalize).join('::')
      end

      def producer_file_header
        [producer_module_name, producer_class_name].join('::')
      end

      def queue_name
        [message_broker.queue_prefix, 'producers'].compact.join('_')
      end
    end
  end
end
