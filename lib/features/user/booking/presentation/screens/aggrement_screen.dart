import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/show_progress_indicator.dart';
import 'package:fidden/core/utils/constants/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/constants/app_sizes.dart';
import '../../controller/user_waiver_controller.dart';

class AgreementScreen extends StatefulWidget {
  const AgreementScreen({super.key, required this.businessId});

  final String businessId;

  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  final controller = Get.put(UserWaiverBookingController());

  @override
  void initState() {
    super.initState();
    // Delay to make sure it's outside the initial build phase
    Future.delayed(Duration.zero, () {
      controller.fetchWaiverDetails(widget.businessId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: "Agreement Screen",
          color: const Color(0xff212121),
          fontWeight: FontWeight.w600,
          fontSize: getWidth(24),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: Column(
                  children: [
                    SizedBox(height: getHeight(350)),
                    ShowProgressIndicator(),
                  ],
                ),
              );
            }
            if (controller.waiverDetails.value.data?.agreement == null ||
                controller.waiverDetails.value.data?.agreement?.isEmpty ==
                    true) {
              return Center(
                child: CustomText(
                  text: "No Agreement Found",
                  color: const Color(0xff656565),
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w400,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: "Acknowledgment & Consent:",
                  color: const Color(0xff232323),
                  fontSize: getWidth(24),
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: getHeight(16)),
                ListView.separated(
                  separatorBuilder: (context, index) =>
                      SizedBox(height: getHeight(10)),
                  itemCount:
                      controller.waiverDetails.value.data!.agreement!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final agreement =
                        controller.waiverDetails.value.data?.agreement?[index];
                    return agreement?.dropdown == "Acknowledgment & Consent"
                        ? CustomTerms(
                            secondText:
                                controller
                                    .waiverDetails
                                    .value
                                    .data
                                    ?.agreement?[index]
                                    .textField1 ??
                                '',
                          )
                        : SizedBox.shrink();
                  },
                ),
                SizedBox(height: getWidth(35)),
                CustomText(
                  text: "Aftercare Instructions Provided:",
                  color: const Color(0xff232323),
                  fontSize: getWidth(24),
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: getHeight(16)),
                ListView.separated(
                  separatorBuilder: (context, index) =>
                      SizedBox(height: getHeight(10)),
                  itemCount:
                      controller.waiverDetails.value.data!.agreement!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final agreement =
                        controller.waiverDetails.value.data?.agreement?[index];
                    return agreement?.dropdown ==
                            "Aftercare Instructions Provided"
                        ? CustomTerms(
                            secondText:
                                controller
                                    .waiverDetails
                                    .value
                                    .data
                                    ?.agreement?[index]
                                    .textField1 ??
                                '',
                          )
                        : SizedBox.shrink();
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class CustomTerms extends StatelessWidget {
  const CustomTerms({super.key, required this.secondText});

  final String secondText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            SizedBox(height: getHeight(10)),
            Image.asset(
              IconPath.dotIcon,
              height: getHeight(5),
              width: getWidth(5),
            ),
          ],
        ),
        SizedBox(width: getWidth(15)),
        Column(
          children: [
            SizedBox(
              width: getWidth(350),
              child: CustomText(
                text: secondText,
                color: const Color(0xff656565),
                fontWeight: FontWeight.w400,
                fontSize: getWidth(14),
                textAlign: TextAlign.start,
                maxLines: 3,
              ),
            ),
            SizedBox(height: getHeight(10)),
          ],
        ),
      ],
    );
  }
}
