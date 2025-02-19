import 'package:wisteria/vm/vm.dart';

final class VmTests {
  int passed = 0;

  Future<VirtualMachine> _runTest(String asm, {bool quietMode = true}) async {
    final vm = VirtualMachine(() {}, quietMode: quietMode, programString: asm);
    vm.run();

    return vm;
  }

  Future testMovLiteral() async {
    const code = "mov rax 10";
    final vm = await _runTest(code);

    assert(vm.ra == 10);
    passed++;
  }

  Future testMovRegister() async {
    const code = "mov rbx 10 mov rax rbx";
    final vm = await _runTest(code);

    assert(vm.ra == 10);
    passed++;
  }

  Future testAddLiteral() async {
    const code = "add rax 5";
    final vm = await _runTest(code);

    assert(vm.ra == 5);
    passed++;
  }

  Future testAddRegister() async {
    const code = "mov rbx 10 mov rax 5 add rax rbx";
    final vm = await _runTest(code);

    assert(vm.ra == 15);
    passed++;
  }

  Future testAnything() async {
    const code = 
"""
start:

""";

    final vm = await _runTest(code, quietMode: false);

    assert(true);
    passed++;
  }

  void runAllTests() async {
    await testAnything();

    var tests = {
      // "MOV Literal Instruction":  testMovLiteral,
      // "MOV Register Instruction": testMovRegister,
      // "ADD Literal Instruction":  testAddLiteral,
      // "ADD Register Instruction": testAddLiteral,
    };

    print("Virtual Machine Tests:");
    for (var entry in tests.entries) {
      print("  Running: ${entry.key}");
      await entry.value();
    }

    print("$passed / ${tests.length} tests passing");
  }
}