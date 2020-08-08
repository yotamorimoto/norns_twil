-- a tape machine
-- 
local tm = {}
tm.__index = tm

local function new(self,d,v,i,o,r,n)
  local self = {
    device  = d,
    voice   = v,
    _loop_i = i,
    _loop_o = o,
    _rate   = r,
    notes   = n,
    index   = 0,
    map = {},
  }
  return setmetatable(self, tm)
end

-- just stuff
local midiratio = function(n) return math.pow(2,n*(1/12)) end

-- metamethods
function tm:__tostring() return ('tm: %s'):format(self.notes) end

function tm:init()
  for i,v in ipairs(self.notes) do self.map[v] = i end
  self.rate_table = {
    -- just intonation
    -1.2, -0.75, -0.5, 1, 0.25, 0.5, 0.75, 1,
    -- 12et phrygian - 5 semitones
    midiratio(-5), midiratio(-4), midiratio(-2), midiratio(0), 
    midiratio(2), midiratio(3), midiratio(5), midiratio(6)
  }
  self.i_rate_table = {}
  for i,v in ipairs(self.rate_table) do self.i_rate_table[v] = self.notes[i] end
end

function tm:update_position(pos)
  self.device:note_off(self.notes[self.index], 0,1)
  self.index = util.round((pos - self._loop_i)*(16/(self._loop_o - self._loop_i)), 1) + 1
  self.device:note_on(self.notes[self.index], WHITE, 1)
end
-- softcut
function tm:position_(pos) 
  softcut.position(self.voice, pos) 
end
function tm:rate_(rate)
  softcut.rate(self.voice, rate) 
end

-- tm
function tm:position(note)
  self:position_((self.map[note]-1)*((self._loop_o - self._loop_i)/16) + self._loop_i)
end
function tm:show_rate()
  local note = self.i_rate_table[self._rate]
  self.device:note_on(note, BLUE, 1)
end
function tm:rate(note)
  self._rate = self.rate_table[self.map[note]]
  self:rate_(self._rate)
  for i,v in ipairs(self.notes) do self.device:note_off(v,0,1) end
  self.device:note_on(note, BLUE, 1)
end
function tm:loop_o(loop_o)
  softcut.loop_end(self.voice, loop_o)
  self._loop_o = loop_o
end

-- module exports:
return {
  new = new; -- ctor
  __object = tm -- object table/metatable
}