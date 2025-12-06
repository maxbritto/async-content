import 'package:async_content/async_content.dart';
import 'package:flutter/material.dart';

@Deprecated(
    'Use official ListenableBuilder class with a LoadableContentViewModel instead + router to call the start loading content when needed')
enum ContentIn { expanded, singleChildScrollView, none }

class LoadableContentBuilder<T extends LoadableContentViewModel>
    extends StatelessWidget {
  final T viewModel;
  final bool reloadDataOnEachBuild;
  final Widget? child;
  final Widget? loadIndicator;
  final ContentIn contentIn;
  final Widget Function(BuildContext context, T viewModel, Widget? child)
      builder;
  const LoadableContentBuilder(
      {required this.viewModel,
      required this.builder,
      this.child,
      this.loadIndicator,
      this.reloadDataOnEachBuild = false,
      this.contentIn = ContentIn.expanded});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future(
            () => viewModel.loadContentToDisplay(force: reloadDataOnEachBuild)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            return loadIndicator ?? Center(child: CircularProgressIndicator());
          }
          return ListenableBuilder(
            key: const Key("viewmodel-watcher"),
            listenable: viewModel,
            builder: (context, child) {
              final errorTitle = viewModel.loadingErrorTitle;
              if (contentIn == ContentIn.singleChildScrollView) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    children: [
                      if (errorTitle != null)
                        LoadedContentErrorView(viewModel: viewModel),
                      builder(context, viewModel, child),
                    ],
                  ),
                );
              } else if (contentIn == ContentIn.none) {
                if (errorTitle != null) {
                  return Column(children: [
                    LoadedContentErrorView(viewModel: viewModel),
                    builder(context, viewModel, child),
                  ]);
                } else {
                  return builder(context, viewModel, child);
                }
              } else {
                return Column(
                  children: [
                    if (errorTitle != null)
                      LoadedContentErrorView(viewModel: viewModel),
                    Expanded(child: builder(context, viewModel, child)),
                  ],
                );
              }
            },
            child: child,
          );
        });
  }
}
