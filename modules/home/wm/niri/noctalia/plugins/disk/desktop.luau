--!nonstrict

local HISTORY = 180
local history = {}
local latest = nil

local function formatGib(value)
  return string.format("%.0f GiB", value / (1024 * 1024 * 1024))
end

local function render()
  local header = latest ~= nil and string.format("/  %.0f%%", latest.usagePercent) or "/"
  local rows = {
    ui.label({
      text = header,
      fontSize = 14,
      fontWeight = "bold",
    }),
  }

  if latest == nil then
    table.insert(rows, ui.label({
      text = "нет данных",
      fontSize = 12,
      color = "on_surface_variant",
    }))
  else
    local used = latest.totalBytes - latest.freeBytes
    local free = latest.availableBytes or latest.freeBytes

    table.insert(rows, ui.progress({
      progress = math.max(0, math.min(1, latest.usagePercent / 100)),
      fill = "primary",
      width = 220,
      height = 6,
      radius = 3,
    }))

    table.insert(rows, ui.label({
      text = string.format("Занято %s · Свободно %s", formatGib(used), formatGib(free)),
      fontSize = 12,
      color = "on_surface_variant",
    }))

    local values = history
    if #values > 0 and #values < 4 then
      values = { values[1], values[1], values[1], values[1] }
    end

    if #values > 0 then
      table.insert(rows, ui.graph({
        values = values,
        color = "primary",
        lineWidth = 2,
        fillOpacity = 0.2,
        width = 220,
        height = 48,
      }))

      table.insert(rows, ui.label({
        text = "30 мин",
        fontSize = 10,
        color = "on_surface_variant",
      }))
    end
  end

  desktopWidget.render(ui.column({
    gap = 6,
    padding = 12,
    align = "start",
  }, rows))
end

local function update()
  noctalia.setUpdateInterval(10000)

  local disk = noctalia.diskStats("/")
  latest = disk

  if disk ~= nil then
    history[#history + 1] = math.max(0, math.min(1, disk.usagePercent / 100))
    if #history > HISTORY then
      table.remove(history, 1)
    end
  end

  render()
end

update()
