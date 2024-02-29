import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../admin/data/firestore_admin_repository.dart';
import '../../progress/data/firestore_progress_repository.dart';
import '../../schedule/data/firestore_schedule_repository.dart';
import '../data/firestore_color_codes_repository.dart';
import '../data/firestore_experiment_repository.dart';

class ExperimentService {
  ExperimentService({
    required this.firestoreExperimentRepository,
    required this.firestoreAdminRepository,
    required this.firestoreColorCodesRepository,
    required this.firestoreScheduleRepository,
    required this.firestoreProgressRepository,
  });

  final FirestoreExperimentRepository firestoreExperimentRepository;
  final FirestoreAdminRepository firestoreAdminRepository;
  final FirestoreColorCodesRepository firestoreColorCodesRepository;
  final FirestoreScheduleRepository firestoreScheduleRepository;
  final FirestoreProgressRepository firestoreProgressRepository;

  /// adding a new experiment, schedules, etc.
  Future<void> addNewExperiment({
    required String experimentName,
    required String experimentLocation,
    required String adminUid,
  }) async {
    // add new experiment document
    final experimentDocId = await firestoreExperimentRepository.addExperimentDoc(
      experimentName: experimentName,
      experimentLocation: experimentLocation,
      adminUid: adminUid,
    );

    // add reference to newly created experiment to admin doc
    await firestoreAdminRepository.addExperimentToAdmin(
      experimentDocId: experimentDocId,
      adminUid: adminUid,
    );

    // short wait to allow security rules to catch up
    await Future.delayed(const Duration(milliseconds: 100));

    // copy color codes document to experiment sub-collection
    await firestoreColorCodesRepository.copyColorCodesToExperiment(
      experimentDocId: experimentDocId,
    );

    // add new parameter document
    firestoreScheduleRepository.addParameterDoc(experimentDocId);

    // add new schedule documents
    firestoreScheduleRepository.addScheduleDocs(experimentDocId);

    // add new progress document
    firestoreProgressRepository.addProgressDoc(experimentDocId);
  }
}

final experimentServiceProvider = Provider<ExperimentService>((ref) {
  return ExperimentService(
    firestoreExperimentRepository: ref.watch(firestoreExperimentRepositoryProvider),
    firestoreAdminRepository: ref.watch(firestoreAdminRepositoryProvider),
    firestoreColorCodesRepository: ref.watch(firestoreColorCodesRepositoryProvider),
    firestoreScheduleRepository: ref.watch(firestoreScheduleRepositoryProvider),
    firestoreProgressRepository: ref.watch(firestoreProgressRepositoryProvider),
  );
});
