module SimpleForm
  module Inputs
    class BooleanInput < Base
      def input
        if nested_boolean_style?
          label_options = label_html_options.dup
          label_options[:label] = ''

          build_hidden_field_for_checkbox +
            @builder.label(nil, label_options) {
              build_check_box_without_hidden_field + inline_label
            }
        else
          build_check_box
        end
      end

      def label_input
        apply_label_input_options(options)

        if options[:label] == false
          input
        elsif nested_boolean_style?
          build_hidden_field_for_checkbox +
            @builder.label(label_target, label_html_options) {
              build_check_box_without_hidden_field + label_text
            }
        else
          input + label
        end
      end

      private

      # Build a checkbox tag using default unchecked value. This allows us to
      # reuse the method for nested boolean style, but with no unchecked value,
      # which won't generate the hidden checkbox. This is the default functionality
      # in Rails > 3.2.1, and is backported in SimpleForm AV helpers.
      def build_check_box(unchecked_value = unchecked_value)
        @builder.check_box(attribute_name, input_html_options, checked_value, unchecked_value)
      end

      # Build a checkbox without generating the hidden field. See
      # #build_hidden_field_for_checkbox for more info.
      def build_check_box_without_hidden_field
        build_check_box(nil)
      end

      # Create a hidden field for the current checkbox, so we can simulate Rails
      # functionality with hidden + checkbox, but under a nested context, where
      # we need the hidden field to be *outside* the label (otherwise it
      # generates invalid html - html5 only).
      def build_hidden_field_for_checkbox
        @builder.hidden_field(attribute_name, :value => unchecked_value, :id => nil,
                              :disabled => input_html_options[:disabled],
                              :name => input_html_options[:name])
      end

      def inline_label
        inline_option = options[:inline_label]
        inline_option == true ? label_text : inline_option
      end

      # Booleans are not required by default because in most of the cases
      # it makes no sense marking them as required. The only exception is
      # Terms of Use usually presented at most sites sign up screen.
      def required_by_default?
        false
      end

      def checked_value
        options.fetch(:checked_value, '1')
      end

      def unchecked_value
        options.fetch(:unchecked_value, '0')
      end
    end
  end
end
