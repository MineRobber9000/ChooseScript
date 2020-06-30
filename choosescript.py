from sly import Lexer as SlyLexer

commands = ["goto","print","choose","input","set","testequals","check","beq","bne","pause"]

class Lexer(SlyLexer):
	tokens = { STEM, COMMAND, TARGET, STRING, NUMBER, BOOLEAN }
	ignore = ' \t'

	TARGET = r'([A-Za-z][A-Za-z0-9_]*):'

	def TARGET(self,t):
		t.value = t.value.strip()[:-1]
		assert t.value not in commands, f"Cannot use name of command {t.value} as branch/goto target"
		return t

	BOOLEAN = r'(true|false)'

	def BOOLEAN(self,t):
		t.value = t.value=="true"
		return t

	COMMAND = '('+'|'.join(commands)+')'
	STEM = r'([A-Za-z][A-Za-z0-9_]*)'

	@_(r'"(?:[^"\\]|\\.)*"')
	def STRING(self,t):
		t.value = eval(t.value)
		return t

	@_(r'\n+')
	def ignore_newline(self,t):
		self.lineno+=len(t.value)

	@_(r"[#][^#]+[#]")
	def ignore_comment(self,t):
		self.lineno+=t.value.count("\n")

	NUMBER = r'\d+'

	def NUMBER(self,t):
		t.value = int(t.value)
		return t

class DummyToken:
	def __getattr__(self):
		return None

import sys
def caller_id():
	return sys._getframe(2).f_code.co_name

import time
class Evaluator:
	def __init__(self): pass
	def run(self,prog):
		if type(prog)!=list: prog = list(Lexer().tokenize(prog))
		self.prog = prog
		self.pos = 0
		self.values = dict()
		self.flag = False
		while self.pos<len(self.prog):
			tok = self.prog[self.pos]
			self.pos+=1
			if hasattr(self,"do_"+tok.type):
				try:
					getattr(self,"do_"+tok.type)(tok)
				except AssertionError as e:
					msg = e.args[0]
					print("Error: "+msg)
					return
			else:
				print(f"Error: invalid state with token {tok.type} ({tok.value!r}) at line {tok.lineno!s}")
				return
	def next(self,*types):
		cmd = caller_id()[len("command_"):]
		assert self.pos<len(self.prog), f"unexpected EOF after command {cmd}"
		if not types: types = Lexer.tokens
		tok = self.prog[self.pos]
		assert tok.type in types, f"invalid argument type {tok.type} for command {cmd}"
		self.pos+=1
		return tok
	def peek(self):
		cmd = caller_id()[len("command_"):]
		try:
			return self.prog[self.pos]
		except:
			return DummyToken()
	def do_TARGET(self,t):
		# just needs to be here so TARGET tokens don't cause an error
		return
	def do_COMMAND(self,t):
		if hasattr(self,"command_"+t.value):
			getattr(self,"command_"+t.value)()
		else:
			print(f"Error: unimplemented command {t.value!r} at line {t.lineno!s}")
	@property
	def targets(self):
		targets = {}
		for i, t in enumerate(self.prog):
			if t.type=="TARGET":
				targets[t.value]=i
		return targets
	def expand_values(self,s):
		for key, value in self.values.items():
			s = s.replace("{{"+key+"}}",str(value))
		return s
	def command_goto(self):
		target = self.next("STEM")
		assert target.value in self.targets, f"Invalid goto target {target.value} at line {target.lineno}!"
		self.pos = self.targets[target.value]
	def command_print(self):
		val = self.next("STRING").value
		val = self.expand_values(val)
		print(val)
	def command_choose(self):
		choices = dict()
		while self.peek().type=="STRING":
			label = self.next("STRING")
			target = self.next("STEM")
			assert target.value in self.targets, f"Invalid goto target {target.value} in choose statement on line {target.lineno}"
			choices[label.value]=target.value
		for i, label in enumerate(choices.keys(),1):
			print(f"{i}.) {label}")
		inp = input("? ").strip()
		try:
			inp = int(inp)-1
			assert inp>=0 and inp<len(choices.keys())
			self.pos = self.targets[choices[list(choices.keys())[inp]]]
		except: pass
	def command_input(self):
		key = self.next("STEM").value
		prompt = self.next("STRING").value
		print(self.expand_values(prompt))
		empty = "You must give a value!"
		if self.peek().type=="STRING":
			empty = self.expand_values(self.next("STRING").value)
		val = input("? ").strip()
		while not val:
			print(empty)
			val = input("? ").strip()
		self.values[key]=val
	def command_set(self):
		key = self.next("STEM").value
		val = self.next("STRING","NUMBER","BOOLEAN").value
		self.values[key]=val
	def command_testequals(self):
		key = self.next("STEM").value
		if key not in self.values:
			self.flag=False
			return
		self.flag = self.values[key]==self.next("STRING","NUMBER","BOOLEAN").value
	def command_check(self):
		key = self.next("STEM").value
		if key not in self.values:
			self.flag=False
			return
		assert type(self.values[key])==bool, f"Cannot use check on non-boolean value {self.values[key]!r}!"
		self.flag = self.values[key]
	def command_beq(self):
		target = self.next("STEM")
		assert target.value in self.targets, f"Invalid branch target {target.value} at line {target.lineno}!"
		if not self.flag: return
		self.pos = self.targets[target.value]
	def command_bne(self):
		target = self.next("STEM")
		assert target.value in self.targets, f"Invalid branch target {target.value} at line {target.lineno}!"
		if self.flag: return
		self.pos = self.targets[target.value]
	def command_pause(self):
		if self.peek().type=="NUMBER":
			time.sleep(self.next("NUMBER").value)
		else:
			input("Press enter to continue.")

if __name__=="__main__":
	_, file = sys.argv
	with open(file) as f:
		script = f.read()
	evaluator = Evaluator()
	evaluator.run(script)
