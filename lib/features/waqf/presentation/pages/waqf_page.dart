import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waqf_insight/features/waqf/presentation/bloc/waqf_bloc.dart';
import 'package:waqf_insight/features/waqf/presentation/bloc/waqf_event.dart';
import 'package:waqf_insight/features/waqf/presentation/bloc/waqf_state.dart';

/// Main page for displaying Waqf items.
///
/// Uses [BlocBuilder] to reactively render UI based on [WaqfState].
class WaqfPage extends StatelessWidget {
  const WaqfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأوقاف'),
      ),
      body: BlocBuilder<WaqfBloc, WaqfState>(
        builder: (context, state) {
          if (state is WaqfInitial) {
            // Trigger initial data load
            context.read<WaqfBloc>().add(const GetAllWaqfsEvent());
            return const SizedBox.shrink();
          }

          if (state is WaqfLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is WaqfLoaded) {
            if (state.waqfs.isEmpty) {
              return const Center(
                child: Text('لا توجد أوقاف حالياً'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WaqfBloc>().add(const RefreshWaqfsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.waqfs.length,
                itemBuilder: (context, index) {
                  final waqf = state.waqfs[index];
                  return Card(
                    child: ListTile(
                      title: Text(waqf.name),
                      subtitle: Text(waqf.location),
                      trailing: Chip(label: Text(waqf.status)),
                      onTap: () {
                        // Navigate to waqf details
                      },
                    ),
                  );
                },
              ),
            );
          }

          if (state is WaqfError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<WaqfBloc>().add(const GetAllWaqfsEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
