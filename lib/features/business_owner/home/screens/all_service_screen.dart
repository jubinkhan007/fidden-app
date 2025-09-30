import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/show_progress_indicator.dart';
import 'package:fidden/core/utils/constants/app_colors.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/core/utils/constants/image_path.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/constants/icon_path.dart';
import 'add_service_screen.dart';
import 'edit_service_screen.dart';

class AllServiceScreen extends StatelessWidget {
  const AllServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BusinessOwnerController>();
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: Text('Service'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        actions: [
          Obx(() {
            // Disable the button if the user can't add a service
            final canAdd = controller.canAddService;
            return GestureDetector(
              onTap: canAdd
                  ? () => Get.to(() => AddServiceScreen())
                  : () => Get.snackbar(
                      "No Business Profile",
                      "Please create a business profile before adding services.",
                      snackPosition: SnackPosition.BOTTOM,
                    ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  IconPath.plusIcon,
                  height: getHeight(26),
                  width: getWidth(26),
                  color: canAdd ? null : Colors.grey, // Visual feedback
                ),
              ),
            );
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchAllMyService(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getHeight(24)),
              Padding(
                padding: EdgeInsets.only(left: getWidth(22)),
                child: CustomText(
                  text: "All Service List",
                  fontSize: getWidth(18),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: getHeight(12)),
              Obx(() {
                if (controller.isLoading.value &&
                    controller.allServiceList.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(height: getHeight(300)),
                        ShowProgressIndicator(),
                      ],
                    ),
                  );
                }
                if (controller.allServiceList.isEmpty) {
                  return Center(
                    child: CustomText(
                      text: "No service created",
                      color: AppColors.textGrey,
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.allServiceList.length,
                  itemBuilder: (context, index) {
                    final service = controller.allServiceList[index];
                    return ListTile(
                      leading: SizedBox(
                        height: getHeight(50),
                        width: getWidth(50),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  (service.serviceImg != null &&
                                      service.serviceImg!.isNotEmpty)
                                  ? NetworkImage(service.serviceImg!)
                                  : AssetImage(ImagePath.servicePlaceholder)
                                        as ImageProvider,
                            ),
                            if (service.isActive != null)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: service.isActive!
                                        ? Colors.green
                                        : Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      title: CustomText(
                        text: service.title ?? '',
                        fontSize: getWidth(16),
                        fontWeight: FontWeight.w600,
                      ),
                      subtitle: CustomText(
                        text: service.description ?? "",
                        fontSize: getWidth(14),
                        fontWeight: FontWeight.w400,
                        color: Color(0xff6B7280),
                        textOverflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                () => EditServiceScreen(
                                  id: service.id.toString(),

                                ),
                              );
                            },
                            child: Image.asset(
                              IconPath.editIcon,
                              height: getHeight(20),
                              width: getWidth(20),
                              color: Color(0xff7A49A5),
                            ),
                          ),
                          SizedBox(height: getHeight(8)),
                          CustomText(
                            text: '\$${service.price}',
                            fontSize: getWidth(16),
                            fontWeight: FontWeight.w500,
                            color: Color(0xff111827),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
