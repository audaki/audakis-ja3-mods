TextStyles.ConsoleLog.TextFont = 'droid, 10, bold'

if not origConsolePrint then
  origConsolePrint = ConsolePrint
end

g_audaBufferSize = 2048

function ConsolePrint(text)
  text = text or ''

  local lines = {}
  for line in text:gmatch('[^\r\n]+') do
    lines[#lines + 1] = line
  end

  local buffer = ''
  for _, line in ipairs(lines) do
    if #line >= 1 then
      if #buffer + #line + 1 < g_audaBufferSize then
        if #buffer >= 1 then
          buffer = buffer .. '\n' .. line
        else
          buffer = line
        end
      else
        origConsolePrint(buffer)
        buffer = line
      end
    end
  end

  if #buffer >= 1 then
    origConsolePrint(buffer)
  end
end

print = CreatePrint({''})




CurrentModOptions.properties[1].Test = 42
