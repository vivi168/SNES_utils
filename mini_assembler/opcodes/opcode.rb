require 'yaml'
opcodes = File.read('opcodes.txt').split("\n").map { |l| l.split(' ') }

modes = {
  'acc' => :acc,
  'imp' => :imp,
  'imm' => :imm,
  'iml' => :iml,
  'imm8' => :imm8,
  'imm16' => :imm16,
  'stk,S' => :sr,
  'dir' => :dp,
  'dir,X' => :dpx,
  'dir,Y' => :dpy,
  '(dir)' => :idp,
  '(dir,X)' => :idx,
  '(dir),Y' => :idy,
  '[dir]' => :idl,
  '[dir],Y' => :idly,
  '(stk,S),Y' => :isy,
  'abs' => :abs,
  'abs,X' => :abx,
  'abs,Y' => :aby,
  'long' => :abl,
  'long,X' => :alx,
  '(abs)' => :ind,
  '(abs,X)' => :iax,
  '[abs]' => :ial,
  'rel8' => :rel,
  'rel16' => :rell,
  'src,dest' => :bm
}

regexes = {
  acc: /^$/,
  imp: /^$/,
  imm: /^\$?([0-9a-f]{1,2})$/i,
  iml: /^\$?([0-9a-f]{1,2})$/i,
  imm8: /^#\$?([0-9a-f]{1,2})$/i,
  imm16: /^#\$?([0-9a-f]{3,4})$/i,
  sr: /^\$?([0-9a-f]{1,2}),S$/i,
  dp: /^\$?([0-9a-f]{1,2})$/i,
  dpx: /^\$?([0-9a-f]{1,2}),X$/i,
  dpy: /^\$?([0-9a-f]{1,2}),Y$/i,
  idp: /^\(\$?([0-9a-f]{1,2})\)$/i,
  idx: /^\(\$?([0-9a-f]{1,2}),X\)$/i,
  idy: /^\(\$?([0-9a-f]{1,2})\),Y$/i,
  idl: /^\[\$?([0-9a-f]{1,2})\]$/i,
  idly: /^\[\$?([0-9a-f]{1,2})\],Y$/i,
  isy: /^\(\$?([0-9a-f]{1,2}),S\),Y$/i,
  abs: /^\$?([0-9a-f]{3,4})$/i,
  abx: /^\$?([0-9a-f]{3,4}),X$/i,
  aby: /^\$?([0-9a-f]{3,4}),Y$/i,
  abl: /^\$?([0-9a-f]{5,6})$/i,
  alx: /^\$?([0-9a-f]{5,6}),X$/i,
  ind: /^\(\$?([0-9a-f]{3,4})\)$/i,
  iax: /^\(\$?([0-9a-f]{3,4}),X\)$/i,
  ial: /^\[\$?([0-9a-f]{3,4})\]$/i,
  rel: /^\$?([0-9a-f]{3,4})$/i,
  rell: /^\$?([0-9a-f]{3,4})$/i,
  bm: /^\$?([0-9a-f]{1,2}),\$?([0-9a-f]{1,2})$/i
}


opcodes_arr = opcodes[2..-1].map do |opcode|
  mode_syntax = opcode[2]
  mode = modes[mode_syntax]
  op = opcode[0]
  len = opcode[1]
  mnemonic = opcode[3]

  [mnemonic, mode, op, len]
end

opcodes_hash = {}

opcodes_arr.each do |opcode|
  opcodes_hash[opcode[0].to_sym] = {} unless opcodes_hash[opcode[0].to_sym].is_a? Hash
  opcodes_hash[opcode[0].to_sym][opcode[1].to_sym] = [opcode[2], opcode[3]]
end

puts opcodes_hash.to_yaml
