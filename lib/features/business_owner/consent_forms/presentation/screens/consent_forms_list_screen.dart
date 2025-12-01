import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/consent_form_controller.dart';

class ConsentFormsListScreen extends StatelessWidget {
  const ConsentFormsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConsentFormController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Consent Forms'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Templates'),
              Tab(text: 'Signed Forms'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TemplatesTab(controller: controller),
            _SignedFormsTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _TemplatesTab extends StatelessWidget {
  final ConsentFormController controller;

  const _TemplatesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.templates.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.templates.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No consent templates available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchTemplates,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.templates.length,
          itemBuilder: (context, index) {
            final template = controller.templates[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: template.isDefault ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  child: Icon(
                    Icons.description,
                    color: template.isDefault ? Colors.blue : Colors.grey,
                  ),
                ),
                title: Text(
                  template.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  template.content.length > 100 
                      ? '${template.content.substring(0, 100)}...' 
                      : template.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: template.isDefault
                    ? const Chip(
                        label: Text('Default', style: TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )
                    : null,
                onTap: () => _showTemplateDetail(context, template),
              ),
            );
          },
        ),
      );
    });
  }

  void _showTemplateDetail(BuildContext context, dynamic template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template.title),
        content: SingleChildScrollView(
          child: Text(template.content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SignedFormsTab extends StatelessWidget {
  final ConsentFormController controller;

  const _SignedFormsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.signedForms.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.signedForms.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No signed forms yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchSignedForms,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.signedForms.length,
          itemBuilder: (context, index) {
            final form = controller.signedForms[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.check_circle, color: Colors.green),
                ),
                title: Text(
                  form.user.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(form.user.email),
                    const SizedBox(height: 4),
                    Text(
                      'Signed: ${form.signedAt.toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSignatureDialog(context, form),
              ),
            );
          },
        ),
      );
    });
  }

  void _showSignatureDialog(BuildContext context, dynamic form) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signature'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              form.signatureUrl,
              height: 150,
              errorBuilder: (_, __, ___) => Container(
                height: 150,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 48),
              ),
            ),
            const SizedBox(height: 16),
            Text('Signed by: ${form.user.name}'),
            Text('On: ${form.signedAt}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
