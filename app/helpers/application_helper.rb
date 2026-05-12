module ApplicationHelper
  def render_locations(array)
    if Array(array).present?
      content_tag(:ul, class: "list-disc list-inside space-y-1 text-gray-700") do
        Array(array).map { |loc| content_tag(:li, loc) }.join.html_safe
      end
    else
      content_tag(:span, "–", class: "text-gray-400 italic")
    end
  end
  def nav_link(name, path, icon = nil, extra_class = "")
    is_active = current_page?(path) ? "bg-lime-600" : ""
    icon_svg = icon ? heroicon(icon) : ""
    link_to raw("#{icon_svg}<span class='ml-2'>#{name}</span>"), path,
            class: "flex items-center px-3 py-2 rounded hover:bg-lime-600 #{is_active} #{extra_class}"
  end

  def heroicon(name)
    icons = {
      "home" => "<svg class='w-4 h-4' fill='none' stroke='currentColor' stroke-width='2'
                   viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round'
                   d='M3 12l2-2m0 0l7-7 7 7m-9 2v8m4-8v8m5-8l2 2m-2-2v6a2 2 0 01-2 2h-4a2 2 0 01-2-2v-6' /></svg>",

      "download" => "<svg class='w-4 h-4' fill='none' stroke='currentColor' stroke-width='2'
                      viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round'
                      d='M4 16v2a2 2 0 002 2h12a2 2 0 002-2v-2M12 12v6m0 0l-3-3m3 3l3-3M12 4v8' /></svg>",

      "database" => "<svg class='w-4 h-4' fill='none' stroke='currentColor' stroke-width='2'
                      viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round'
                      d='M12 4c4.418 0 8 1.343 8 3s-3.582 3-8 3-8-1.343-8-3 3.582-3 8-3z
                      M4 9v6c0 1.657 3.582 3 8 3s8-1.343 8-3V9M4 15v6c0 1.657 3.582 3 8 3s8-1.343 8-3v-6' /></svg>",

      "map" => "<svg class='w-4 h-4' fill='none' stroke='currentColor' stroke-width='2'
                viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round'
                d='M9 20l-5.447-2.724A2 2 0 013 15.382V5.618a2 2 0 011.553-1.894L9 2m0 0l6 2m-6-2v18
                m6-16l5.447 2.724A2 2 0 0121 8.618v9.764a2 2 0 01-1.553 1.894L15 22V4z' /></svg>",

      "bar-chart" => "<svg class='w-4 h-4' fill='none' stroke='currentColor' stroke-width='2'
                      viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round'
                      d='M3 3v18h18M9 17v-6M15 17v-10' /></svg>",

      "file-text" => "<svg class='w-4 h-4' fill='none' stroke='currentColor' stroke-width='2'
                      viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round'
                      d='M8 16h8M8 12h8m-6 8h6a2 2 0 002-2V7l-6-6H6a2 2 0 00-2 2v12a2 2 0 002 2h2z' /></svg>",

      "line-chart" => "<svg class='w-4 h-4' fill='none' stroke='currentColor' stroke-width='2'
                       viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round'
                       d='M3 3v18h18M4 14l6-6 4 4 6-6' /></svg>",

      "cpu" => "<svg class='w-4 h-4' fill='none' stroke='currentColor' stroke-width='2'
                viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round'
                d='M9 9h6v6H9z M4 4v4m0 4v4m0 4v4m4-20h4m4 0h4m0 4v4m0 4v4m0 4v4M4 4h16v16H4z' /></svg>",

      "users" => "<svg class='w-4 h-4' fill='none' stroke='currentColor' stroke-width='2'
                  viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round'
                  d='M17 20h5v-2a4 4 0 00-5-4M9 20H4v-2a4 4 0 015-4m0-6a4 4 0 100-8 4 4 0 000 8zm12 4a4 4 0 10-8 0 4 4 0 008 0z' /></svg>",

      "log-out" => "<svg class='w-4 h-4' fill='none' stroke='currentColor' stroke-width='2'
                    viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round'
                    d='M17 16l4-4m0 0l-4-4m4 4H7m6 4v1m0-10V5a2 2 0 00-2-2H5a2 2 0 00-2 2v14a2 2 0 002 2h6a2 2 0 002-2v-1' /></svg>"
    }

    icons[name] || ""
  end
end
