local url_count = 0
local item_name = os.getenv("item_name")

local start_id_str = string.match(item_name, "([0-9]+):")
local end_id_str = string.match(item_name, ":([0-9]+)")

local id_string_table = {}


-- http://lua-users.org/wiki/RangeIterator
-- range(a) returns an iterator from 1 to a (step = 1)
-- range(a, b) returns an iterator from a to b (step = 1)
-- range(a, b, step) returns an iterator from a to b, counting by step.
function range(a, b, step)
  if not b then
    b = a
    a = 1
  end
  step = step or 1
  local f =
  step > 0 and
  function(_, lastvalue)
    local nextvalue = lastvalue + step
    if nextvalue <= b then return nextvalue end
  end or
  step < 0 and
  function(_, lastvalue)
    local nextvalue = lastvalue + step
    if nextvalue >= b then return nextvalue end
  end or
  function(_, lastvalue) return lastvalue end
  return f, nil, a - step
end


for id in range(tonumber(start_id_str), tonumber(end_id_str)) do
  id_string_table[tostring(id)] = true
end


read_file = function(file)
  if file then
    local f = io.open(file)
    local data = f:read("*all")
    f:close()
    return data or ""
  else
    return ""
  end
end


wget.callbacks.download_child_p = function(urlpos, parent, depth, start_url_parsed, iri, verdict, reason)
  -- io.stdout:write('url '.. urlpos['url']['url'] .. " " ..tostring(verdict).."\n")


  if string.match(urlpos['url']['url'], "bebo%.com/") then
    if verdict and urlpos["link_inline_p"] == 1 then
      verdict = true
    elseif verdict
    and id_string_table[string.match(urlpos['url']['url'], "[^a-z]MemberId=([0-9]+)")] then
      verdict = true
    else
      verdict = false
    end
  end

  -- io.stdout:write('url '.. urlpos['url']['url'] .. " " ..tostring(verdict).."\n")
  return verdict
end


wget.callbacks.httploop_result = function(url, err, http_stat)
  -- NEW for 2014: Slightly more verbose messages because people keep
  -- complaining that it's not moving or not working
  io.stdout:write(url_count .. "=" .. url["url"] .. ".  \r")
  io.stdout:flush()
  url_count = url_count + 1

  -- We're okay; sleep a bit (if we have to) and continue
  local sleep_time = 0.1 * (math.random(75, 125) / 100.0)

  -- there's no time for sleep
  sleep_time = 0

  if string.match(url["host"], "s%.bebo%.com")
  or string.match(url["host"], "i[0-9]+%.bebo%.com") then
    -- We should be able to go fast on images since that's what a web browser does
    sleep_time = 0
  end

  if sleep_time > 0.001 then
    os.execute("sleep " .. sleep_time)
  end

  return wget.actions.NOTHING
end


wget.callbacks.get_urls = function(file, url, is_css, iri)
  local urls = {}

  if string.match(url, "Profile%.jsp%?MemberId=[0-9]+$") then
    local html = read_file(file)

    if not string.match(html, 'html') then
      return urls
    end

    if string.match(html, 'notfound">') then
      return urls
    end

    local profile_id = string.match(url, "Profile%.jsp%?MemberId=([0-9]+)$")

    if profile_id then
      io.stdout:write("\nFound Profile "..profile_id.."\n")
      io.stdout:flush()

      local new_url = 'http://archive.bebo.com/Wall.jsp?MemberId='..profile_id

      table.insert(urls, {
        url=new_url
      })
    end
  end

  return urls
end