import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/experiments/domain/experiment.dart';
import 'package:pencil_game_admin/features/survey/data/firestore_survey_repository.dart';

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
    required this.firestoreSurveyRepository,
  });

  final FirestoreExperimentRepository firestoreExperimentRepository;
  final FirestoreAdminRepository firestoreAdminRepository;
  final FirestoreColorCodesRepository firestoreColorCodesRepository;
  final FirestoreScheduleRepository firestoreScheduleRepository;
  final FirestoreProgressRepository firestoreProgressRepository;
  final FirestoreSurveyRepository firestoreSurveyRepository;

  /// adding a new experiment, schedules, etc.
  Future<void> addNewExperiment({
    required String experimentName,
    required String experimentLocation,
    required Treatment treatment,
    required String adminUid,
    required bool showSurvey,
  }) async {
    // add new experiment document
    final experimentDocId =
        await firestoreExperimentRepository.addExperimentDoc(
            experimentName: experimentName,
            experimentLocation: experimentLocation,
            adminUid: adminUid,
            treatment: treatment,
            showSurvey: false);

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

    // add new schedule document
    firestoreScheduleRepository.addScheduleDoc(experimentDocId);

    // add new progress document
    firestoreProgressRepository.addProgressDoc(experimentDocId);

    // add survey document
    // //TODO: REPLACE HARDCODED LINK
    // firestoreSurveyRepository.addSurveyStatusToExperiment(
    //   experimentDocId: experimentDocId,
    // );
  }
}

final experimentServiceProvider = Provider<ExperimentService>((ref) {
  return ExperimentService(
    firestoreExperimentRepository:
        ref.watch(firestoreExperimentRepositoryProvider),
    firestoreAdminRepository: ref.watch(firestoreAdminRepositoryProvider),
    firestoreColorCodesRepository:
        ref.watch(firestoreColorCodesRepositoryProvider),
    firestoreScheduleRepository: ref.watch(firestoreScheduleRepositoryProvider),
    firestoreProgressRepository: ref.watch(firestoreProgressRepositoryProvider),
    firestoreSurveyRepository: ref.watch(firestoreSurveyRepositoryProvider),
  );
});
