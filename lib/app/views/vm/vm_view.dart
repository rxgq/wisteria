import 'package:simple_icons/simple_icons.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wisteria/app/app_controller.dart';
import 'package:wisteria/app/views/vm/console_box.dart';
import 'package:wisteria/app/widgets/wisteria_box.dart';
import 'package:wisteria/app/widgets/wisteria_button.dart';
import 'package:wisteria/app/widgets/wisteria_text.dart';
import 'package:wisteria/app/constants.dart';
import 'package:wisteria/app/views/vm/stdout_box.dart';
import 'package:wisteria/app/views/vm/utils/vm_view_controller.dart';
import 'package:wisteria/vm/constants.dart';
import 'package:wisteria/vm/vm.dart';
import '../../utils/preferences.dart';
import 'code_editor.dart';

class VmView extends StatefulWidget {
  const VmView({super.key});

  @override
  State<VmView> createState() => _VmViewState();
}

class _VmViewState extends State<VmView> {
  final controller = VmViewController();

  @override
  void initState() {
    super.initState();
    controller.vm = VirtualMachine(() {}, programString: "");
    initVm();

    WidgetsFlutterBinding.ensureInitialized();
    initHelpDialogue();
  }

  double buttonWidth(Size screen) {
    return ((screen.width - 40) / widthFactor / 4) - boxPadding * 8;
  }

  Future<void> initHelpDialogue() async {
    final alreadyShown = await AppController.instance.getPreference(shownInitialHelpDialoguePref);
    if (alreadyShown == "true") {
      return;
    }

    await AppController.instance.setPreference(shownInitialHelpDialoguePref, "true");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return helpDialog();
        },
      );
    });
  }

  Future<void> initVm() async {
    await controller.initVm();
    setState(() {});
  }

  void setInitialInfoWidget(Size screen) {
    // the infoWidget is by default set to a SizedBox at the beginning, therefore
    // this code will run once at the beginning.
    //
    // this is to prevent this from being set every time setState is called as
    // this method is called in build()
    if (controller.infoWidget is SizedBox) {
      controller.infoWidget = WisteriaBox(
        width: screen.width / widthFactor + 12, 
        height: infoWidgetHeight,
        color: primaryGrey,
        child: Padding(
          padding: const EdgeInsets.all(boxPadding),
          child: defaultInfoWidget(screen)
        ),
      );
    }

    if (!controller.shouldShowDialogue) {
      controller.infoWidget = const SizedBox();
    }
  }

  void setInfoWidget(Widget infoWidget) {
    final screen = MediaQuery.sizeOf(context);

    controller.infoWidget = WisteriaBox(
      width: screen.width / widthFactor + 12, 
      height: infoWidgetHeight,
      color: primaryGrey,
      child: Padding(
        padding: const EdgeInsets.all(boxPadding),
        child: infoWidget
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    setInitialInfoWidget(screen);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          Row(
            children: [
              title(),

              const Spacer(),

              // githubLinkIcon(),
            ],
          ),
              
          const Spacer(),

          const SizedBox(height: 16),
          homeView(screen),
          const SizedBox(height: 8),
            
          const Spacer(),

          Padding(
            padding: EdgeInsets.only(left: (screen.width - (screen.width / widthFactor)) / 2 - 8),
            child: controller.infoWidget,
          )
        ],
      ),
    );
  }

  Widget defaultInfoWidget(Size screen) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(boxPadding),
        child: WisteriaText(
          text: "try tapping on a component to find out more about it", 
          color: primaryWhite, 
          size: 14
        ),
      ),
    );
  }

  Widget title() {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: WisteriaText(
        text: "virtual machine",
        color: primaryTextColor, 
        size: 24
      ),
    );
  }

  Widget homeView(Size screen) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: (screen.width / widthFactor) + boxPadding * 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(boxBorderRadius),
            color: primaryGrey,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              userInterface(screen),
              ConsoleBox(
                vm: controller.vm, 
                width: (screen.width / widthFactor) + boxPadding * 2,
                showBorder: false,
              ),
              cpuInterface(screen)
            ],
          ),
        ),
      ),
    );
  }

  Widget userInterface(Size screen) {
    return Padding(
      padding: const EdgeInsets.only(
        top: boxPadding,
        left: boxPadding,
        right: boxPadding
      ),
      child: WisteriaBox(
        width: screen.width,
        height: userInterfaceHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StdoutBox(screen: screen, vm: controller.vm),
        
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                executeButton(screen),
                codeEditorButton(screen),
                pauseButton(screen),
                haltButton(screen),
                resetButton(screen)
              ],
            ),
          ],
        )
      ),
    );
  }

  Widget githubLinkIcon() {
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            final Uri url = Uri.parse(githubUrl);
            
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: boxPadding * 4,
              right: boxPadding * 4 + 4
            ),
            child: Icon(
              SimpleIcons.github,
              color: primaryTextColor,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }


  Widget resetButton(Size screen) {
    return Padding(
      padding: const EdgeInsets.only(
        right: boxPadding * 2, left: boxPadding * 2
      ),
      child: WisteriaButton(
        width: buttonWidth(screen),
        color: primaryGrey,
        text: "reset",
        onTap: () async {
          controller.onReset(setState);
          setState(() {});
        }
      ),
    );
  }

  Widget haltButton(Size screen) {
    return Padding(
      padding: const EdgeInsets.only(
        left: boxPadding * 2
      ),
      child: WisteriaButton(
        width: buttonWidth(screen),
        color: primaryGrey,
        text: "halt",
        onTap: () async {
          controller.onHalt();
          setState(() {});
        }
      ),
    );
  }

  Widget pauseButton(Size screen) {
    return Padding(
      padding: const EdgeInsets.only(
        left: boxPadding * 2
      ),
      child: WisteriaButton(
        width: 28,
        height: 32,
        color: primaryGrey, 
        showBorder: controller.vm.isPaused,
        icon: controller.vm.isPaused ? Icons.pause : Icons.play_arrow,
        onTap: () {
          controller.onPause();
          setState(() {});
        }
      ),
    );
  }

  Widget executeButton(Size screen) {
    return Padding(
      padding: const EdgeInsets.only(
        left: boxPadding * 2
      ),
      child: WisteriaButton(
        width: buttonWidth(screen),
        color: primaryGrey,
        text: "execute",
        onTap: () {
          controller.onExecute(setState);
          setState(() {});
        }
      ),
    );
  }

  Widget codeEditorButton(Size screen) {
    return Padding(
      padding: const EdgeInsets.only(
        left: boxPadding * 2
      ),
      child: WisteriaButton(
        width: buttonWidth(screen),
        color: primaryGrey,
        text: "edit code",
        onTap: () {
          showDialog(context: context, builder: (context) {
            return CodeEditor(
              controller: AppController.instance.codeController
            );
          });
        }
      ),
    );
  }

  Widget asmBox() {
    return GestureDetector(
      onTap: () {
        controller.onComponentTapped("asm");
        if (controller.selectedComponentName == "") {
          setState(() {});
          return;
        }

        controller.selectedComponentName = "asm";

        setInfoWidget(asmInfoWidget());
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.only(
            left: boxPadding,
            bottom: boxPadding,
            top: boxPadding
          ),
          child: WisteriaBox(
            showBorder: controller.selectedComponentName == "asm",
            header: "assembly",
            width: asmBoxWidth,
            height: 70,
            color: primaryGrey,
            child: Padding(
              padding: const EdgeInsets.all(boxPadding),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: WisteriaText(
                  text: AppController.instance.codeController.text,
                  color: primaryWhite,
                  size: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget machineCodeBox(Size screen) {
    return GestureDetector(
      onTap: () {
        controller.onComponentTapped("machine code");
        if (controller.selectedComponentName == "") {
          setState(() {});
          return;
        }

        controller.selectedComponentName = "machine code";

        setInfoWidget(machineCodeInfoWidget());
      },
      child: Padding(
        padding: const EdgeInsets.only(
          right: boxPadding,
          bottom: boxPadding,
          top: boxPadding
        ),
        child: WisteriaBox(
          showBorder: controller.selectedComponentName == "machine code",
          header: "machine code",
          width: (screen.width / widthFactor - asmBoxWidth) - boxPadding * 4,
          height: 70,
          color: primaryGrey,
          child: Padding(
            padding: const EdgeInsets.all(boxPadding),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: WisteriaText(
                text: controller.vm.program.map((e) => e.toRadixString(2).padLeft(8, '0')).join(" "),
                color: primaryWhite,
                size: 12,
              ),
            ),
          )
        ),
      ),
    );
  }

  Widget vmRegister(String name, int val, double width, double height) {
    return Padding(
      padding: const EdgeInsets.only(bottom: boxPadding),
      child: GestureDetector(
        onTap: () {
          controller.onComponentTapped(name);
          if (controller.selectedComponentName == "") {
            setState(() {});
            return;
          }

          setInfoWidget(registerInfoWidget());
        },
        child: WisteriaBox(
          width: width,
          height: height,
          header: name,
          showBorder: controller.selectedComponentName == name,
          color: primaryGrey,
          child: Center(
            child: WisteriaText(
              text: val.toString(),
              color: Colors.white,
              size: 13,
            ),
          )
        ),
      ),
    );
  }

  Widget memoryBox(Size screen) {
    return Padding(
      padding: const EdgeInsets.all(boxPadding),
      child: WisteriaBox(
        width: 160,
        height: 120,
        header: "memory",
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            childAspectRatio: 1.0
          ),
          itemCount: controller.vm.memory.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                controller.onMemoryCellClicked(index);
                if (controller.selectedMemoryIdx == -1) {
                  setState(() {});
                  return;
                }

                setInfoWidget(memoryCellInfoWidget());
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: controller.selectedMemoryIdx != index ? null : Border.all(color: const Color.fromARGB(255, 138, 138, 138)),
                  color: primaryGrey,
                ),
                alignment: Alignment.center,
                child: Text(
                  controller.decimalToHex(controller.vm.memory[index]),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget cpuInterface(Size screen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: boxPadding),
      child: WisteriaBox(
        width: (screen.width / widthFactor) + boxPadding * 2,
        height: cpuInterfaceHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                asmBox(),
                machineCodeBox(screen),
              ],
            ),
      
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  children: [
                    flagBox("zf", controller.vm.zf),
                    flagBox("sf", controller.vm.sf),
                    const SizedBox(height: 2),

                    programCounter(),
                  ],
                ),
      
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        vmRegister(R1_NAME, controller.vm.ra, 50, 32),
                        vmRegister(R2_NAME, controller.vm.rb, 50, 32),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        vmRegister(R3_NAME, controller.vm.rc, 50, 32),
                        vmRegister(R4_NAME, controller.vm.rd, 50, 32),
                      ],
                    ),
                  ],
                ),
                
                const Spacer(),

                memoryBox(screen),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget programCounter() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: boxPadding, 
        left: boxPadding
      ),
      child: GestureDetector(
        onTap: () {
          controller.onProgramCounterTapped();
          if (!controller.programCounterSelected) {
            setState(() {});
            return;
          }

          setInfoWidget(programCounterInfoWidget());
        },
        child: WisteriaBox(
          width: 60, 
          height: 32,
          color: primaryGrey,
          header: "pc",
          showBorder: controller.programCounterSelected,
          child: Center(
            child: WisteriaText(
              text: controller.vm.pc.toString(), 
              color: primaryWhite, 
              size: 14
            ),
          )
        ),
      ),
    );
  }

  Widget memoryCellInfoWidget() {
    final cell = controller.vm.memory[controller.selectedMemoryIdx];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WisteriaText(
          text: "Memory Cell (${controller.decimalToHex(controller.selectedMemoryIdx)}) (${cell.toString()})", 
          color: primaryWhite,
          size: 18
        ),
        const SizedBox(height: 4),

        const SizedBox(height: 16),
        WisteriaText(
          text: memoryDescription, 
          color: primaryWhite,
          size: 12
        ),
      ],
    );
  }

  Widget flagInfoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WisteriaText(
          text: "Flag ${controller.selectedComponentName} (${controller.getFlagValue(controller.selectedComponentName)})", 
          color: primaryWhite,
          size: 18
        ),
        const SizedBox(height: 4),

        WisteriaText(
          text: flagDescription, 
          color: primaryWhite,
          size: 12
        ),
      ],
    );
  }

  Widget asmInfoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WisteriaText(
          text: "Assembly Language", 
          color: primaryWhite,
          size: 18
        ),
        const SizedBox(height: 16),
        WisteriaText(
          text: asmDesc, 
          color: primaryWhite,
          size: 12
        ),
      ],
    );
  }

  Widget machineCodeInfoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WisteriaText(
          text: "Machine Code", 
          color: primaryWhite,
          size: 18
        ),
        const SizedBox(height: 16),
        WisteriaText(
          text: machineCodeDesc, 
          color: primaryWhite,
          size: 12
        ),
      ],
    );
  }

  Widget registerInfoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WisteriaText(
          text: "Register ${controller.selectedComponentName} (${controller.getRegisterValue(controller.selectedComponentName)})", 
          color: primaryWhite,
          size: 18
        ),
        const SizedBox(height: 4),

        WisteriaText(
          text: registerDescription, 
          color: primaryWhite,
          size: 12
        ),
      ],
    );
  }

  Widget flagBox(String name, bool value) {
    return GestureDetector(
      onTap: () {
        controller.onComponentTapped(name);
        if (controller.selectedComponentName == "") {
          setState(() {});
          return;
        }
    
        setInfoWidget(flagInfoWidget());
      },
      child: WisteriaBox(
        width: 40,
        height: 20,
        header: name,
        showBorder: controller.selectedComponentName == name,
        color: primaryGrey,
        child: Center(
          child: WisteriaText(
            text: (value ? 1 : 0).toString(),
            color: Colors.white,
            size: 13,
          ),
        )
      ),
    );
  }

  Widget programCounterInfoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WisteriaText(
          text: "Program Counter (${controller.vm.pc})", 
          color: primaryWhite,
          size: 18
        ),

        const SizedBox(height: 4),
        WisteriaText(
          text: programCounterDescription, 
          color: primaryWhite,
          size: 12
        ),
      ],
    );
  }

  Widget helpDialog() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WisteriaBox(
          width: 270, 
          height: 350, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: WisteriaText(
                    text: "Welcome to Wisteria", 
                    color: primaryTextColor, 
                    size: 15
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: WisteriaText(
                  text: helpMessage, 
                  color: primaryTextColor, 
                  size: 12
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WisteriaButton(
                    width: 80, 
                    color: primaryGrey, 
                    text: "okay", 
                    onTap: () {
                      Navigator.pop(context);
                    }
                  ),
                ],
              ),

              const SizedBox(height: 16)
            ],
          )
        ),
      ],
    );
  }
}