module ApplicationHelper
  def flash_class(level)
    case level.to_sym
    when :notice then "bg-blue-100 border-blue-500 text-blue-700"
    when :success then "bg-green-100 border-green-500 text-green-700"
    when :error then "bg-red-100 border-red-500 text-red-700"
    when :alert then "bg-yellow-100 border-yellow-500 text-yellow-700"
    else "bg-gray-100 border-gray-500 text-gray-700"
    end
  end

  def currency_format(amount)
    number_to_currency(amount, precision: 2)
  end

  def status_badge(status)
    colors = {
      'pending' => 'bg-yellow-100 text-yellow-800',
      'processing' => 'bg-blue-100 text-blue-800',
      'shipped' => 'bg-purple-100 text-purple-800',
      'delivered' => 'bg-green-100 text-green-800',
      'cancelled' => 'bg-red-100 text-red-800'
    }
    
    content_tag :span, status.titleize, class: "px-2 py-1 rounded-full text-xs font-semibold #{colors[status]}"
  end
end
