obs = obslua

cloudflared_path = "cloudflared"
websocket_port = 4455
auto_start = false
tunnel_mode = "quick"
custom_tunnel_name = "obs-tunnel"
tunnel_pid = 0
is_running = false
public_url = ""
launch_id = ""
log_file_path = ""
err_file_path = ""
prop_toggle_btn = nil
prop_copy_btn = nil
prop_stop_btn = nil
prop_start_btn = nil
script_props_ref = nil
script_settings_ref = nil

function script_description()
  return "Start/stop Cloudflare Tunnel for OBS WebSocket with copy-link support."
end

local function log_info(msg) obs.script_log(obs.LOG_INFO, "[cloudflare_tunnel] " .. msg) end
local function log_warn(msg) obs.script_log(obs.LOG_WARNING, "[cloudflare_tunnel] " .. msg) end
local function trim(s) if not s then return "" end return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
local function esc_sq(s) return (s or ""):gsub("'", "''") end

local function run_capture(cmd)
  local p = io.popen(cmd, "r")
  if not p then return nil end
  local out = p:read("*a")
  p:close()
  return out
end

local function is_tunnel_running()
  return is_running
end

local function detect_running_tunnel()
  local out = run_capture('cmd /c tasklist /FI "IMAGENAME eq cloudflared.exe"')
  if not out then return false end
  return out:lower():find("cloudflared.exe", 1, true) ~= nil
end

local function is_custom_mode()
  return tunnel_mode == "custom"
end

local function refresh_public_url_from_log()
  local content = ""

  if log_file_path ~= "" then
    local f1 = io.open(log_file_path, "r")
    if f1 then
      content = content .. (f1:read("*a") or "")
      f1:close()
    end
  end

  if err_file_path ~= "" then
    local f2 = io.open(err_file_path, "r")
    if f2 then
      content = content .. "\n" .. (f2:read("*a") or "")
      f2:close()
    end
  end

  if content == "" then return false end
  local url = content:match("(https://[%w%-%.]+%.trycloudflare%.com/?)")
  if url and url ~= "" then
    public_url = url
    return true
  end
  return false
end

local function update_button_states()
  if prop_start_btn then
    obs.obs_property_set_description(prop_start_btn, is_tunnel_running() and "Stop Tunnel" or "Start Tunnel")
  end
  if prop_copy_btn then
    obs.obs_property_set_enabled(prop_copy_btn, is_tunnel_running() and not is_custom_mode())
  end
end

local function update_mode_visibility(props)
  if not props then return end
  local p_name = obs.obs_properties_get(props, "custom_tunnel_name")
  local p_guide = obs.obs_properties_get(props, "open_custom_guide")
  local show = is_custom_mode()
  if p_name then obs.obs_property_set_visible(p_name, show) end
  if p_guide then obs.obs_property_set_visible(p_guide, show) end
end

local function refresh_properties_ui()
  if script_props_ref and script_settings_ref and obs.obs_properties_apply_settings then
    obs.obs_properties_apply_settings(script_props_ref, script_settings_ref)
  end
end

local function poll_tunnel_log()
  if not is_tunnel_running() then
    obs.timer_remove(poll_tunnel_log)
    update_button_states()
    return
  end
  local changed = refresh_public_url_from_log()
  update_button_states()
  if changed then
    refresh_properties_ui()
  end
end

local function start_tunnel()
  if is_tunnel_running() then return end

  launch_id = tostring(os.time())
  local tmp = os.getenv("TEMP") or ""
  if tmp == "" then tmp = ".\\" end
  if not tmp:match("[\\/]$") then tmp = tmp .. "\\" end
  log_file_path = tmp .. "obs-cloudflared-tunnel-" .. launch_id .. ".out.log"
  err_file_path = tmp .. "obs-cloudflared-tunnel-" .. launch_id .. ".err.log"
  public_url = ""

  local ps
  if is_custom_mode() then
    local tunnel_name = trim(custom_tunnel_name)
    if tunnel_name == "" then
      log_warn("Custom tunnel name vacio.")
      return
    end
    ps = string.format(
      "$ErrorActionPreference='SilentlyContinue'; Remove-Item -LiteralPath '%s' -ErrorAction SilentlyContinue; Remove-Item -LiteralPath '%s' -ErrorAction SilentlyContinue; Start-Process -FilePath '%s' -ArgumentList @('--logfile','%s','--loglevel','info','tunnel','run','%s') -WindowStyle Hidden",
      esc_sq(log_file_path), esc_sq(err_file_path), esc_sq(cloudflared_path), esc_sq(log_file_path), esc_sq(tunnel_name)
    )
  else
    ps = string.format(
      "$ErrorActionPreference='SilentlyContinue'; Remove-Item -LiteralPath '%s' -ErrorAction SilentlyContinue; Remove-Item -LiteralPath '%s' -ErrorAction SilentlyContinue; Start-Process -FilePath '%s' -ArgumentList @('tunnel','--url','http://localhost:%d','--logfile','%s','--loglevel','info') -WindowStyle Hidden",
      esc_sq(log_file_path), esc_sq(err_file_path), esc_sq(cloudflared_path), websocket_port, esc_sq(log_file_path)
    )
  end
  local cmd = "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command \"" .. ps .. "\""
  os.execute(cmd)

  tunnel_pid = 1
  is_running = true
  obs.timer_remove(poll_tunnel_log)
  obs.timer_add(poll_tunnel_log, 1000)
  log_info("Tunnel start requested.")
  update_button_states()
end

local function stop_tunnel()
  if is_running then
    os.execute('powershell -NoProfile -Command "Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue"')
  end
  tunnel_pid = 0
  is_running = false
  public_url = ""
  obs.timer_remove(poll_tunnel_log)
  update_button_states()
end

function on_start_clicked(props, prop)
  if is_tunnel_running() then
    stop_tunnel()
  else
    start_tunnel()
  end
  update_button_states()
  return true
end

function on_toggle_clicked(props, prop)
  if is_tunnel_running() then stop_tunnel() else start_tunnel() end
  return false
end

function on_copy_url_clicked(props, prop)
  local final_url = ""
  if is_custom_mode() then
    log_warn("En modo custom domain, copia tu hostname final (wss://tu-dominio) segun la guia.")
    return false
  else
    refresh_public_url_from_log()
    if public_url == "" then
      log_warn("Todavia no hay URL publica. Espera unos segundos o revisa el log: " .. tostring(log_file_path))
      return false
    end
    final_url = public_url
  end

  if not final_url:match("/$") then
    final_url = final_url .. "/"
  end
  os.execute("powershell -NoProfile -Command \"Set-Clipboard -Value '" .. esc_sq(final_url) .. "'\"")
  log_info("Link copiado.")
  return false
end

function on_stop_clicked(props, prop)
  stop_tunnel()
  update_button_states()
  return true
end

function on_open_custom_guide_clicked(props, prop)
  os.execute('cmd /c start "" "https://github.com/oKidd/obs-ws-tunnel/blob/main/custom-domain-tunnel.md"')
  return false
end

function on_mode_changed(props, prop, settings)
  tunnel_mode = obs.obs_data_get_string(settings, "tunnel_mode")
  update_mode_visibility(props)
  return true
end

function script_properties()
  local props = obs.obs_properties_create()
  obs.obs_properties_add_text(props, "cloudflared_path", "cloudflared path", obs.OBS_TEXT_DEFAULT)
  obs.obs_properties_add_int(props, "websocket_port", "obs-websocket port", 1, 65535, 1)
  local mode_prop = obs.obs_properties_add_list(props, "tunnel_mode", "Tunnel mode", obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_STRING)
  obs.obs_property_list_add_string(mode_prop, "Quick URL (random)", "quick")
  obs.obs_property_list_add_string(mode_prop, "Custom Domain (named tunnel)", "custom")
  obs.obs_property_set_modified_callback(mode_prop, on_mode_changed)
  obs.obs_properties_add_text(props, "custom_tunnel_name", "Custom tunnel name", obs.OBS_TEXT_DEFAULT)
  obs.obs_properties_add_button(props, "open_custom_guide", "Open Custom Domain Guide", on_open_custom_guide_clicked)
  obs.obs_properties_add_bool(props, "auto_start", "Auto-start tunnel on OBS launch")
  prop_start_btn = obs.obs_properties_add_button(props, "start_btn", "Start Tunnel", on_start_clicked)
  prop_copy_btn = obs.obs_properties_add_button(props, "copy_url_btn", "Copy Link", on_copy_url_clicked)
  script_props_ref = props
  update_mode_visibility(props)
  update_button_states()
  return props
end

function script_defaults(settings)
  obs.obs_data_set_default_string(settings, "cloudflared_path", "cloudflared")
  obs.obs_data_set_default_int(settings, "websocket_port", 4455)
  obs.obs_data_set_default_string(settings, "tunnel_mode", "quick")
  obs.obs_data_set_default_string(settings, "custom_tunnel_name", "obs-tunnel")
  obs.obs_data_set_default_bool(settings, "auto_start", false)
end

function script_update(settings)
  script_settings_ref = settings
  cloudflared_path = obs.obs_data_get_string(settings, "cloudflared_path")
  websocket_port = obs.obs_data_get_int(settings, "websocket_port")
  tunnel_mode = obs.obs_data_get_string(settings, "tunnel_mode")
  custom_tunnel_name = obs.obs_data_get_string(settings, "custom_tunnel_name")
  auto_start = obs.obs_data_get_bool(settings, "auto_start")
  update_mode_visibility(script_props_ref)
  update_button_states()
end

function script_load(settings)
  script_update(settings)
  if detect_running_tunnel() then
    is_running = true
    tunnel_pid = 1
    refresh_public_url_from_log()
    update_button_states()
    return
  end

  if auto_start then
    start_tunnel()
  else
    is_running = false
    tunnel_pid = 0
    update_button_states()
  end
end

function script_unload()
  stop_tunnel()
end
