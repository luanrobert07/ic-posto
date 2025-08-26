import 'package:go_router/go_router.dart';
import 'package:posto/features/patient/search_professionals/ui/professional_profiles_list.dart';
import '../../../shared/screens/base_page.dart';
import 'package:flutter/material.dart';

class SearchProfessionalScreen extends StatelessWidget {
  const SearchProfessionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      webPage: webPage(context),
      mobilePage: mobilePage(context),
    );
  }

  Widget webPage(BuildContext context) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
      ),
    ),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.black,
              ),
              child: const Text('Voltar'),
            ),
            const SizedBox(height: 25),
            const ProfessionalProfilesList(),
          ],
        ),
      ),
    ),
  );
}


  Widget mobilePage(BuildContext context) {
    return const Placeholder();
  }
}
