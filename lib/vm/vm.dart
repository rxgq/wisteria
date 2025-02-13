import 'package:flutter/material.dart';
import 'package:wisteria/vm/assembler/assembler.dart';
import 'package:wisteria/vm/constants.dart';
import 'package:wisteria/vm/parser/lexer.dart';

final class VirtualMachine {

  // assembly code to be compiled
  final String programString;

  // machine code to be executed
  List<int> program = [];

  // memory for the virtual machine
  late final List<int> memory;

  // cpu registers
  late final List<int> registers;

  // list of strings to display in the console
  final List<String> consoleOutput = [];

  // stdout for the virtual machine
  final List<String> stdout = [];

  // called when updating the vm state
  final VoidCallback _update;

  // program counter
  int pc = 0;

  // instruction register
  int ir = 0;

  // sign flag
  bool sf = false;

  // zero flag
  bool zf = false;

  // parity flag
  bool pf = false;

  // execution flag for the virtual machine
  bool isRunning = true;

  // will display no messages if true
  bool _quietMode = true;

  // will wait after completing the current instruction instead
  bool isPaused = false;

  // the last error to occur in the vm
  // will return at the earliest point when not null
  String? errorMessage;

  // instruction set architecture
  late final Map<int, Function> isa;

  int get r1 => registers[R1_INDEX];
  set r1(int value) => registers[R1_INDEX] = value;

  int get r2 => registers[R2_INDEX];
  set r2(int value) => registers[R2_INDEX] = value;

  int get r3 => registers[R3_INDEX];
  set r3(int value) => registers[R3_INDEX] = value;

  int get r4 => registers[R4_INDEX];
  set r4(int value) => registers[R4_INDEX] = value;

  VirtualMachine(this._update, {required this.programString, bool quietMode = false}) {
    isa = {
      HLT_OP: _hlt,
      NO_OP: _nop,
      MOV_LIT_OP: _movLiteral,
      MOV_REG_OP: _movRegister,
      ADD_LIT_OP: _addLiteral,
      ADD_REG_OP: _addRegister,
      SUB_LIT_OP: _subLiteral,
      SUB_REG_OP: _subRegister,
      MUL_LIT_OP: _mulLiteral,
      MUL_REG_OP: _mulRegister,
      DIV_LIT_OP: _divLiteral,
      DIV_REG_OP: _divRegister,
      INC_OP: _inc,
      DEC_OP: _dec,
      JUMP_OP: _jump,
      CMP_REG_LIT_OP: _cmpRegLit,
      CMP_REG_REG_OP: _cmpRegReg,
      NEG_OP: _neg,
      JNE_OP: _jne,
      JE_OP: _je,
      AND_OP: _andLiteral,
      OR_OP: _orLiteral,
      XOR_OP: _xorLiteral,
      NOT_OP: _notLiteral,
      OUT_OP: _out
    };

    // 256 * 64(bits) = 2(KiloBytes)
    memory = List.filled(256, 0);
    registers = List.filled(8, 0);

    _quietMode = quietMode;
  }

  Future run() async {
    output("parsing assembly code.");
    await delay(1500);
    
    final lexer = Lexer(program: programString);
    final tokens = lexer.tokenize();
    _update();

    output("assembling into machine code.");
    await delay(3000);

    final assembler = Assembler(tokens: tokens);
    program = assembler.assemble();
    _update();

    _load(program);
    output("loading program into memory.");
    await delay(1000);

    output("loaded ${program.length} bytes.");
    await delay(250);

    output("executing program..");
    
    while (isRunning) {
      await delay(250);

      while (isPaused) {
        await delay(1000);
      }

      _execute();
      _update();

      _tick();
    }

    if (!_quietMode) {
      print("program execution finished");
    }

    output("program execution finished.");
  }

  void _load(List<int> code) {
    for (int i = 0; i < program.length; i++) {
      memory[i] = code[i];
    }
  }

  void _execute() {
    ir = memory[pc];
    _tick();

    _update();

    if (!isa.containsKey(ir)) {
      _error("unknown opcode: $ir");
      return;
    }

    final instruction = isa[ir]!;
    instruction();
  }

  Future<void> delay(int ms) async {
    await Future.delayed(Duration(milliseconds: ms));
  }

  void output(String message) {
    String timestamp = DateTime.now().toLocal().toString().split(' ')[1].split('.')[0];
    consoleOutput.add("[$timestamp] $message");
    _update();
  }

  void _error(String message) {
    if (!_quietMode) {
      print(message);
    }

    errorMessage = message;
  }

  void _movLiteral() {
    final register = memory[pc];
    _tick();

    final literal = memory[pc];

    registers[register] = literal;
  }

  void _movRegister() {
    final register = memory[pc];
    _tick();

    final moveFromRegister = memory[pc];

    registers[register] = registers[moveFromRegister];
  }

  void _addLiteral() {
    final destination = memory[pc];
    _tick();

    final literal = memory[pc];

    registers[destination] += literal;
  }

  void _addRegister() {
    final destination = memory[pc];
    _tick();

    final source = memory[pc];

    registers[destination] += registers[source];
  }

  void _subLiteral() {
    final destination = memory[pc];
    _tick();

    final literal = memory[pc];

    registers[destination] -= literal;
  }

  void _subRegister() {
    final destination = memory[pc];
    _tick();

    final source = memory[pc];

    registers[destination] -= registers[source];
  }

  void _mulLiteral() {
    final destination = memory[pc];
    _tick();

    final source = memory[pc];

    registers[destination] *= source;
  }

  void _mulRegister() {
    final destination = memory[pc];
    _tick();

    final source = memory[pc];

    registers[destination] *= registers[source];
  }

  /// divides the value of r1 by the given argument
  ///   - stores the division result in r1
  ///   - stores the remainder inb r2
  void _divLiteral() {
    final divisor = memory[pc];

    final divisionResult = (r1 / divisor).floor();
    final remainder = r1 % divisor;

    r1 = divisionResult;
    r2 = remainder;
  }

  void _divRegister() {
    final register = memory[pc];
    final divisor = registers[register];

    final divisionResult = (r1 / divisor).floor();
    final remainder = r1 % divisor;

    r1 = divisionResult;
    r2 = remainder;
  }

  void _inc() {
    final register = memory[pc];
    registers[register]++;
  }

  void _dec() {
    final register = memory[pc];
    registers[register]--;
  }

  void _jump() {
    final destination = memory[pc];
    pc = destination;
  }

  void _cmpRegLit() {
    final a = registers[memory[pc]];
    _tick();

    final b = memory[pc];

    zf = a == b;
  }

  void _cmpRegReg() {
    final a = registers[memory[pc]];
    _tick();

    final b = registers[memory[pc]];

    zf = a == b;
  }

  void _jne() {
    if (!zf) {
      final destination = memory[pc];
      pc = destination;
    }

    _update();
  }

  void _je() {
    if (zf) {
      final destination = memory[pc];
      pc = destination;
    }

    _update();
  }

  void _neg() {
    final register = memory[pc];
    registers[register] = -registers[register];
  }

  void _andLiteral() {
    final register = memory[pc];
    _tick();

    final literal = memory[pc];

    final result = registers[register] & literal;
    registers[register] = result;
  }

  void _orLiteral() {
    final register = memory[pc];
    _tick();

    final literal = memory[pc];

    final result = registers[register] | literal;
    registers[register] = result;
  }

  void _xorLiteral() {
    final register = memory[pc];
    _tick();

    final literal = memory[pc];

    final result = registers[register] ^ literal;
    registers[register] = result;
  }

  void _notLiteral() {
    final register = memory[pc];
    registers[register] = ~registers[register];
  }

  void _hlt() {
    isRunning = false;
    _update();
  }

  void _out() {
    stdout.add(registers[memory[pc]].toString());
    _update();
  }

  // this is used as a location to jump to when a label is found
  void _nop() {
    pc--;
  }

  void _tick() {
    pc++;
    _update();
  }
}