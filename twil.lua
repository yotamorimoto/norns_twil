-- :.
-- crossfeeding tape machines

engine.name = 'Test'

-- cosmetics global before include
WHITE = 3
BLUE  = 116
RED   = 56
-- 
XREC = 0.7
XPRE = 0.35
LOOP = 5

local lp  = include('lib/lp')
local tm  = include('lib/tm')
local tms = {}

function update_positions(i,pos)
  if lp.page == 1 then tms[i]:update_position(pos) end
end

function init()
  -------------------------------------- audio
  audio.rev_off()
  audio.level_monitor(1)
  audio.level_eng_cut(1)
  audio.level_adc_cut(1)
  softcut.level_input_cut(1,1,1.0)
  softcut.level_input_cut(2,1,1.0)
  -------------------------------------- launchpad
  lp.connect()
  lp.clear_pads()
  lp.clear_navi()
  lp.clear_head()
  lp.clear_side()
  -------------------------------------- tm
  -- device, voice, loop_in, loop_out, rate, pads
  local li={1.0,1.1,1.2,1.3}
  for voice=1,4 do
    tms[voice] = tm:new(lp.m, voice, li[voice], LOOP, 1, lp.pads[voice])
    tms[voice]:init()
  end
  -- know the machines
  lp.tms = tms
  -- midi handler
  lp.m.event = function(raw)
    local ev = midi.to_msg(raw)
    -- always available
    if ev.type == 'cc' then
      lp.pager(ev)
      lp.play(ev)
    end
    -- page dependent
    if ev.type == 'note_on' then
      if lp.page == 1 then tms[ lp.find_voice(ev.note) ]:position(ev.note) end
      if lp.page == 2 then tms[ lp.find_voice(ev.note) ]:rate(ev.note) end
    end
  end
  -------------------------------------- softcut
  -- player
  local pan = {-1,1,-0.5,0.5}
  local pos = {1,2,3,4}
  local quant = 1/60
  for i=1,4 do
    softcut.enable(i,1)
    softcut.buffer(i,1)
    softcut.loop_start(i,tms[i]._loop_i)
    softcut.loop_end(i,tms[i]._loop_o)
    softcut.position(i,pos[i])
    softcut.rate(i,tms[i]._rate)
    softcut.loop(i,1)
    softcut.play(i,1)
    softcut.pan(i,pan[i])
    softcut.level(i,0)
    softcut.level_slew_time(i,0.01)
    softcut.fade_time(i,0.01)
    softcut.phase_quant(i,quant)
  end
  -- recorder
  softcut.rec(1,1)
  softcut.level_input_cut(1,1,1.0)
  softcut.level_input_cut(2,1,1.0)
  softcut.rec_level(1,0.0)
  softcut.pre_level(1,0.0)
  softcut.level_cut_cut(2,1,0.0)
  -- ready
  softcut.buffer_clear()
  softcut.event_phase(update_positions)
  softcut.poll_start_phase()
end

function enc(n,d)
  if n == 2 then 
    LOOP = util.clamp(LOOP+d/20,1.5,8)
    for i=1,4 do tms[i]:loop_o(LOOP) end
  end
  redraw()
end

function key(n,z)
  if n==2 and z==1 then
    softcut.buffer_clear()
  elseif n==3 and z==1 then
  end
end

function redraw()
  screen.clear()
  screen.move(10,40)
  screen.text('LOOP: ')
  screen.move(118,40)
  screen.text_right(string.format("%.2f",LOOP))
  screen.update()
end

