import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/loyalty_controller.dart';
import '../../data/loyalty_model.dart';

/// Screen for managing loyalty program
class LoyaltyProgramScreen extends StatelessWidget {
  const LoyaltyProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoyaltyController>();
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Loyalty Program'),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          bottom: const TabBar(
            labelColor: Color(0xFFE63946),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFE63946),
            tabs: [
              Tab(text: 'Customers'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCustomersTab(controller),
            _buildSettingsTab(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomersTab(LoyaltyController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.customers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.customers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.loyalty_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No loyalty members yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Customers will appear here when they earn points',
                style: TextStyle(color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: () => controller.fetchCustomers(),
        child: Column(
          children: [
            // Summary bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF52B788).withOpacity(0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('Total Members', controller.customerCount),
                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                  _buildSummaryItem('Can Redeem', controller.redeemableCount),
                ],
              ),
            ),
            
            // Customer list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.customers.length,
                itemBuilder: (context, index) {
                  final customer = controller.customers[index];
                  return _buildCustomerCard(customer, controller);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF52B788),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(LoyaltyCustomer customer, LoyaltyController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    customer.displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      Text(
                        customer.userEmail ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Color(0xFF52B788), size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${customer.pointsBalance}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF52B788),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'points',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            
            // Redeem button
            if (customer.canRedeem)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton.icon(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => _confirmRedeem(customer, controller),
                    icon: const Icon(Icons.card_giftcard, size: 18),
                    label: const Text('Redeem Reward'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52B788),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmRedeem(LoyaltyCustomer customer, LoyaltyController controller) {
    final program = controller.program.value;
    if (program == null) return;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Redeem Reward?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${customer.displayName} will receive:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF52B788).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard, color: Color(0xFF52B788)),
                  const SizedBox(width: 8),
                  Text(
                    program.rewardDisplayText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF52B788),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${program.pointsForRedemption} points will be deducted',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.redeemPoints(userId: customer.userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF52B788),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(LoyaltyController controller) {
    return Obx(() {
      final program = controller.program.value;
      
      if (controller.isLoading.value && program == null) {
        return const Center(child: CircularProgressIndicator());
      }
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active toggle
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.toggle_on, color: Color(0xFF52B788)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loyalty Program',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Enable to reward repeat customers',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: program?.isActive ?? false,
                      onChanged: (val) => controller.toggleProgram(val),
                      activeColor: const Color(0xFF52B788),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Settings
            if (program != null) ...[
              const Text(
                'Program Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              
              _buildSettingItem(
                'Points per Dollar',
                '${program.pointsPerDollar.toStringAsFixed(0)} points',
                Icons.monetization_on_outlined,
              ),
              _buildSettingItem(
                'Points to Redeem',
                '${program.pointsForRedemption} points',
                Icons.redeem,
              ),
              _buildSettingItem(
                'Reward Type',
                program.rewardType.displayName,
                Icons.card_giftcard,
              ),
              _buildSettingItem(
                'Reward Value',
                program.rewardDisplayText,
                Icons.local_offer,
              ),
              
              const SizedBox(height: 24),
              
              // Edit button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showEditSettingsSheet(controller, program),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Settings'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSettingItem(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF52B788)),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showEditSettingsSheet(LoyaltyController controller, LoyaltyProgram program) {
    final pointsPerDollarController = TextEditingController(
      text: program.pointsPerDollar.toStringAsFixed(0),
    );
    final pointsForRedemptionController = TextEditingController(
      text: program.pointsForRedemption.toString(),
    );
    final rewardValueController = TextEditingController(
      text: program.rewardValue.toStringAsFixed(0),
    );
    RewardType selectedRewardType = program.rewardType;
    
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Settings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: pointsPerDollarController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Points per Dollar',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: pointsForRedemptionController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Points to Redeem',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                
                DropdownButtonFormField<RewardType>(
                  value: selectedRewardType,
                  decoration: InputDecoration(
                    labelText: 'Reward Type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: RewardType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => selectedRewardType = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: rewardValueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: selectedRewardType == RewardType.discountPercent
                        ? 'Discount Percentage'
                        : 'Discount Amount (\$)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () async {
                            final success = await controller.updateProgram(
                              pointsPerDollar: double.tryParse(pointsPerDollarController.text),
                              pointsForRedemption: int.tryParse(pointsForRedemptionController.text),
                              rewardType: selectedRewardType,
                              rewardValue: double.tryParse(rewardValueController.text),
                            );
                            
                            if (success) {
                              Get.back();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52B788),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Changes'),
                  )),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
