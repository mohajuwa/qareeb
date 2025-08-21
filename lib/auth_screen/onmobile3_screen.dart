// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qareeb/api_code/signup_controller.dart';
import '../common_code/colore_screen.dart';
import '../common_code/common_button.dart';
import 'onbording_screen.dart';

class Onmobile3Screen extends StatefulWidget {
  const Onmobile3Screen({super.key});

  @override
  State<Onmobile3Screen> createState() => _Onmobile3ScreenState();
}

class _Onmobile3ScreenState extends State<Onmobile3Screen> {
  var sender;
  List<String> list = <String>[
    'Male',
    'Female',
  ];
  List radiolist = [
    'No',
    'Yes',
  ];

  int selected = 0;
  final _formKey = GlobalKey<FormState>();

  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController refercontroller = TextEditingController();

  SignupController signupController = Get.put(SignupController());

  bool obscureText = true;

  // Function to validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    // Regular expression for email validation
    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailRegex).hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required.';
    }
    if (value.length < 8) {
      return 'Name must be at least 8 characters.';
    }
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Name must contain only alphabetic characters.';
    }
    return null; // No validation errors
  }

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: notifier.background,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              color: theamcolore,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: SvgPicture.asset(
                            "assets/svgpicture/lestarroe.svg",
                            color: Colors.white,
                            height: 35,
                          )),
                      // const Expanded(
                      //   child: Divider(color: Colors.white,thickness: 2,),
                      // ),
                      // const SizedBox(width: 5,),
                      const Expanded(
                        child: Divider(
                          color: Colors.white,
                          thickness: 2,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Expanded(
                        child: Divider(
                          color: Colors.white,
                          thickness: 2,
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        "Step 2/2".tr,
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                  // Spacer(),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Just one last thing".tr,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Full Name".tr,
                          style: TextStyle(color: notifier.textColor),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CommonTextfiled400(
                            keyboardType: TextInputType.name,
                            txt: "Name".tr,
                            context: context,
                            controller: namecontroller,
                            validator: _validateName),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Email".tr,
                          style: TextStyle(color: notifier.textColor),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CommonTextfiled400(
                            keyboardType: TextInputType.emailAddress,
                            txt: "email".tr,
                            context: context,
                            controller: emailcontroller,
                            validator: _validateEmail),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Password".tr,
                          style: TextStyle(color: notifier.textColor),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: passwordcontroller,
                          style: TextStyle(color: notifier.textColor),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          obscureText: obscureText,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.red)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.4))),
                            hintText: "Password",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: theamcolore)),
                            suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                  obscureText == true
                                      ? "assets/svgpicture/eye.svg"
                                      : "assets/svgpicture/eye-slash.svg",
                                  color: Colors.grey,
                                  height: 10,
                                  width: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // CommonTextfiled200(txt: "Password".tr, context: context,controller: passwordcontroller),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Referral code(optional)".tr,
                          style: TextStyle(color: notifier.textColor),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: refercontroller,
                          style: TextStyle(color: notifier.textColor),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.red)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.4))),
                            hintText: "Referral code".tr,
                            hintStyle: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: theamcolore)),
                          ),
                        ),
                        // CommonTextfiled200(txt: "Referral code", context: context,controller: refercontroller),
                        const SizedBox(
                          height: 15,
                        ),
                        // Text("Gender",style: TextStyle(color: Colors.black),),
                        // const SizedBox(height: 15,),
                        // DropdownButtonFormField(
                        //   validator: (value) {
                        //     if(value == null){
                        //       return 'Choose your Customer'.tr;
                        //     }
                        //     return null;
                        //   },
                        //   decoration: InputDecoration(
                        //     // hintText: 'Select Status'.tr,
                        //     contentPadding: const EdgeInsets.all(12),
                        //     hintStyle:  TextStyle(fontSize: 14,color: Colors.black),
                        //     border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),borderRadius: BorderRadius.circular(10)),
                        //     enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),borderRadius: BorderRadius.circular(10)),
                        //     disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),borderRadius: BorderRadius.circular(10)),
                        //     focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: theamcolore),borderRadius: BorderRadius.circular(10)),
                        //   ),
                        //   dropdownColor: Colors.white,
                        //   hint: Text("Select Gender".tr,style: TextStyle(fontSize: 14,color: Colors.black)),
                        //   onChanged: (newValue) {
                        //     setState(() {
                        //       sender = newValue;
                        //       print('ghutyg -->  ${sender == "Publish"  ? '0' : '1'}');
                        //       print(' + + + + $newValue');
                        //     });
                        //   },
                        //   value: sender,
                        //   items: list.map<DropdownMenuItem>((item) {
                        //     return DropdownMenuItem(
                        //       value: item,
                        //       child: Text(item,style: TextStyle(color: Colors.black)),
                        //     );
                        //
                        //   }).toList(),
                        // ),
                        // const SizedBox(height: 15,),
                        // Text("Are you a person with disability?",style: TextStyle(color: Colors.black),),
                        // const SizedBox(height: 15,),
                        // ListView.builder(
                        //   padding: EdgeInsets.zero,
                        //   shrinkWrap: true,
                        //   itemCount: radiolist.length,
                        //   itemBuilder: (context, index) {
                        //   return InkWell(
                        //     onTap: () {
                        //       setState(() {
                        //         selected = index;
                        //       });
                        //     },
                        //     child: Padding(
                        //       padding: const EdgeInsets.only(bottom: 8.0),
                        //       child: Container(
                        //         height: 50,
                        //         decoration: BoxDecoration(
                        //           border: Border.all(color: Colors.grey.withOpacity(0.4)),
                        //           borderRadius: BorderRadius.circular(10)
                        //         ),
                        //         child: Padding(
                        //           padding: const EdgeInsets.all(8.0),
                        //           child: Row(
                        //             children: [
                        //               Radio(
                        //                 activeColor: theamcolore,
                        //                 value: selected,
                        //                 groupValue: index,
                        //                 onChanged: (value) {},
                        //               ),
                        //               Text("${radiolist[index]}")
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   );
                        // },)
                      ]),
                  // Spacer(),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(15),
              child: CommonButton(
                  containcolore: theamcolore,
                  onPressed1: () {
                    if (_formKey.currentState!.validate()) {
                      signupController.signupApi(
                          context: context,
                          name: namecontroller.text,
                          email: emailcontroller.text,
                          ccode: ccode,
                          mobilenumber: signupmobilecontroller.text,
                          password: passwordcontroller.text,
                          referral_code: refercontroller.text.isEmpty
                              ? ""
                              : refercontroller.text);

                      // Navigator.push(context, MaterialPageRoute(builder: (context) => const PermissionScreen(),));
                    }
                  },
                  context: context,
                  txt1: "Let's go!".tr),
            )
          ],
        ),
      ),
    );
  }
}
