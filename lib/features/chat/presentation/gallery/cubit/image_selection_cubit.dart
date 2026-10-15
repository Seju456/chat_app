import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/media/image_picker_service.dart';

class ImageSelectionState extends Equatable {
  const ImageSelectionState({required this.paths, this.current = 0});

  final List<String> paths;

  /// Index of the photo shown large.
  final int current;

  bool get isEmpty => paths.isEmpty;
  int get remaining => ImagePickerService.maxImages - paths.length;

  @override
  List<Object?> get props => [paths, current];
}

/// Photos chosen for one message, before they are sent.
class ImageSelectionCubit extends Cubit<ImageSelectionState> {
  ImageSelectionCubit(List<String> initial)
    : super(
        ImageSelectionState(
          paths: initial.take(ImagePickerService.maxImages).toList(),
        ),
      );

  /// Adds photos (skipping duplicates, up to the limit) and shows the first
  /// new one. Returns how many were dropped because of the limit.
  int add(List<String> paths) {
    final fresh = paths.where((p) => !state.paths.contains(p)).toList();
    final accepted = fresh.take(state.remaining).toList();
    if (accepted.isNotEmpty) {
      emit(
        ImageSelectionState(
          paths: [...state.paths, ...accepted],
          current: state.paths.length,
        ),
      );
    }
    return fresh.length - accepted.length;
  }

  void removeAt(int index) {
    final paths = [...state.paths]..removeAt(index);
    emit(
      ImageSelectionState(
        paths: paths,
        current: paths.isEmpty ? 0 : state.current.clamp(0, paths.length - 1),
      ),
    );
  }

  void show(int index) =>
      emit(ImageSelectionState(paths: state.paths, current: index));
}
