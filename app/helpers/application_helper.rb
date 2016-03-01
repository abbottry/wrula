module ApplicationHelper
    def alert_class_for(flash_type)
        { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
    end

    def flash_messages(opts = {})
        flash.each do |msg_type, message|
            concat(content_tag(:div, message, class: "alert #{alert_class_for(msg_type)}") do
                # concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
                concat icon_link_to('remove', nil, nil, class: "close", data: { dismiss: 'alert' })
                concat message
            end)
        end
        nil
    end

    def errors_for(object)
        if object.errors.any?
            content_tag(:div, class: "panel panel-danger") do
                concat(content_tag(:div, class: "panel-heading") do
                    concat(content_tag(:h4, class: "panel-title") do
                        concat "#{pluralize(object.errors.count, "error")} prohibited this #{object.class.name.downcase} from being saved:"
                    end)
                end)
                concat(content_tag(:div, class: "panel-body") do
                    concat(content_tag(:ul) do
                        object.errors.full_messages.each do |msg|
                            concat content_tag(:li, msg)
                        end
                    end)
                end)
            end
        end
    end

    def phone_number_link(text, country_code="1")
        sets_of_numbers = text.scan(/[0-9]+/)
        number = "+#{country_code}-#{sets_of_numbers.join('-')}"
        link_to text, "tel:#{number}"
    end

    def icon_link_to(icon, link_text, link_path, link_options={})
        icon_markup = content_tag(:span, nil, class: "glyphicon glyphicon-#{icon}")

        link_to link_path, link_options do
            safe_join([icon_markup, link_text], " ")
        end
    end
end
