-- lauchpad mini mk3/mk2
-- 
local lp = {}

lp.connect = function() 
  lp.m = midi.connect()
  -- i'm listening...
  lp.m:cc(99,1,3)
end
-- know the machines
lp.tms = nil

lp.page = 0
lp.pads = {
  {81,71,61,51,41,31,21,11,82,72,62,52,42,32,22,12},
  {83,73,63,53,43,33,23,13,84,74,64,54,44,34,24,14},
  {85,75,65,55,45,35,25,15,86,76,66,56,46,36,26,16},
  {87,77,67,57,47,37,27,17,88,78,68,58,48,38,28,18},
}
lp.clear_pads = function()
  for i=1,#lp.pads do
    for j,v in ipairs(lp.pads[i]) do lp.m:note_off(v,0,1) end
  end
end
lp.clear_navi = function()
  lp.m:cc(89,0,1)
  lp.m:cc(79,0,1)
  lp.m:cc(69,0,1)
  lp.m:cc(59,0,1)
end
lp.clear_head = function()
  for i,v in ipairs(lp.toggles_cc) do lp.m:cc(v,0,1) end
end
lp.clear_side = function()
  for i=1,8 do lp.m:cc(i*10+9,0,1) end
end
lp.toggles_cc = {91,92,93,94,95,96,97,98}
lp.toggles = {0,0,0,0,0,0,0,0}

lp.find_voice = function(note)
  local lastd = note % 10
  if lastd == 1 or lastd == 2 then return 1 end
  if lastd == 3 or lastd == 4 then return 2 end
  if lastd == 5 or lastd == 6 then return 3 end
  if lastd == 7 or lastd == 8 then return 4 end
end

lp.pager = function(ev)
  if ev.cc == 89 then 
    lp.page = 1
    lp.clear_pads()
    lp.clear_navi()
    lp.m:cc(ev.cc, WHITE, 1)
  elseif ev.cc == 79 then 
    lp.page = 2
    lp.clear_pads()
    lp.clear_navi()
    lp.m:cc(ev.cc, WHITE, 1)
    for i=1,4 do lp.tms[i]:show_rate() end
  elseif ev.cc == 69 then 
    lp.page = 3
    lp.clear_pads()
    lp.clear_navi()
    lp.m:cc(ev.cc, WHITE, 1)
  elseif ev.cc == 59 then
    lp.page = 4
    lp.clear_pads()
    lp.clear_navi()
    lp.m:cc(ev.cc, WHITE, 1)
  end
end

lp.play = function(ev)
  -- sc for test
  if ev.cc == 19 and ev.val == 127 then engine.ping(1) end
  -- play
  for i=1,4 do
    if ev.cc == lp.toggles_cc[i] and ev.val == 127 then
      if lp.toggles[i] == 0 then
        softcut.level(i,1)
        lp.m:cc(ev.cc,BLUE,1)
        lp.toggles[i] = 1
      else
        softcut.level(i,0)
        lp.m:cc(ev.cc,0,1)
        lp.toggles[i] = 0
      end
    end
  end
  -- rec audio
  if ev.cc == lp.toggles_cc[5] and ev.val == 127 then
    if lp.toggles[5] == 0 then
      softcut.rec_level(1,XREC)
      softcut.pre_level(1,XPRE)
      lp.m:cc(ev.cc,RED,1)
      lp.toggles[5] = 1
    else
      softcut.rec_level(1,0.0)
      softcut.pre_level(1,1.0)
      lp.m:cc(ev.cc,0,1)
      lp.toggles[5] = 0
      end
  end
  if ev.cc == lp.toggles_cc[6] and ev.val == 127 then
    if lp.toggles[6] == 0 then
      softcut.level_cut_cut(2,1,1.0)
      lp.m:cc(ev.cc,RED,1)
      lp.toggles[6] = 1
    else
      softcut.level_cut_cut(2,1,0.0)
      lp.m:cc(ev.cc,0,1)
      lp.toggles[6] = 0
      end
  end
  -- rec gesture??
  if ev.cc == lp.toggles_cc[7] and ev.val == 127 then
    if lp.toggles[7] == 0 then
      lp.m:cc(ev.cc,RED,1)
      lp.toggles[7] = 1
    else
      lp.m:cc(ev.cc,0,1)
      lp.toggles[7] = 0
      end
  end
  if ev.cc == lp.toggles_cc[8] and ev.val == 127 then
    if lp.toggles[8] == 0 then
      lp.m:cc(ev.cc,RED,1)
      lp.toggles[8] = 1
    else
      lp.m:cc(ev.cc,0,1)
      lp.toggles[8] = 0
      end
  end
end

return lp