# frozen_string_literal: true

module MessageBroker
  module Generators
    class ConsumerGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      argument :producer_app_name,
               type: :string,
               description: "App which is producing to topic, e.g. 'users'"

      argument :resource_name,
               type: :string,
               description: "Resource or a category of topic, 'accounts', 'users'"

      argument :event_name,
               type: :string,
               description: "Event name, e.g. 'created', 'updated'"

      class_option :namespace,
                   type: :string,
                   default: nil, desc: "Namespace, e.g. 'sales', 'accounts'"

      def copy_consumer
        empty_directory consumer_dir
        template 'consumer.rb.erb', File.join(consumer_dir, file_name)
      end

      private

      def topic_name
        [producer_app_name, options[:namespace], resource_name].compact.join('_')
      end

      def file_name
        "#{event_name}_job.rb"
      end

      def consumer_dir
        namespace = options[:namespace] || ''
        File.join('app/jobs/consumers', producer_app_name, namespace, resource_name)
      end

      def consumer_class_name
        event_name.capitalize + 'Job'
      end

      def consumer_module_name
        module_name = [producer_app_name, options[:namespace], resource_name]
        module_name.compact.map(&:capitalize).join('::')
      end

      def consumer_file_header
        [consumer_module_name, consumer_class_name].join('::')
      end

      def queue_name
        [message_broker.queue_prefix, 'consumers'].compact.join('_')
      end
    end
  end
end
